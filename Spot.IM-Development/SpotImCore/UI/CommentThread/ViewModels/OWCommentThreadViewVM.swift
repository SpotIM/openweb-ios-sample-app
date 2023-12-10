//
//  OWCommentThreadViewVM.swift
//  SpotImCore
//
//  Created by Alon Shprung on 30/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

// swiftlint:disable file_length

import Foundation
import RxSwift
import RxCocoa

typealias CommentThreadDataSourceModel = OWAnimatableSectionModel<String, OWCommentThreadCellOption>

protocol OWCommentThreadViewViewModelingInputs {
    var willDisplayCell: PublishSubject<WillDisplayCellEvent> { get }
    var tableViewHeight: PublishSubject<CGFloat> { get }
    var viewInitialized: PublishSubject<Void> { get }
    var pullToRefresh: PublishSubject<Void> { get }
    var scrolledToCellIndex: PublishSubject<Int> { get }
    var changeThreadOffset: PublishSubject<CGPoint> { get }
    var closeTapped: PublishSubject<Void> { get }
}

protocol OWCommentThreadViewViewModelingOutputs {
    var title: String { get }
    var shouldShowHeaderView: Bool { get }
    var closeCommentThread: Observable<Void> { get }
    var commentThreadDataSourceSections: Observable<[CommentThreadDataSourceModel]> { get }
    var performTableViewAnimation: Observable<Void> { get }
    var openCommentCreation: Observable<OWCommentCreationTypeInternal> { get }
    var urlClickedOutput: Observable<URL> { get }
    var openProfile: Observable<OWOpenProfileType> { get }
    var scrollToCellIndex: Observable<Int> { get }
    var highlightCellIndex: Observable<Int> { get }
    var shouldShowError: Observable<Void> { get }
    var threadOffset: Observable<CGPoint> { get }
    var dataSourceTransition: OWViewTransition { get }
    var openReportReason: Observable<OWCommentViewModeling> { get }
    var openClarityDetails: Observable<OWClarityDetailsType> { get }
    var updateTableViewInstantly: Observable<Void> { get }
}

protocol OWCommentThreadViewViewModeling {
    var inputs: OWCommentThreadViewViewModelingInputs { get }
    var outputs: OWCommentThreadViewViewModelingOutputs { get }
}

class OWCommentThreadViewViewModel: OWCommentThreadViewViewModeling, OWCommentThreadViewViewModelingInputs, OWCommentThreadViewViewModelingOutputs {
    var inputs: OWCommentThreadViewViewModelingInputs { return self }
    var outputs: OWCommentThreadViewViewModelingOutputs { return self }

    fileprivate struct Metrics {
        static let defaultNumberOfReplies: Int = 5
        static let numberOfSkeletonComments: Int = 10
        static let spacingBetweenCommentsDivisor: CGFloat = 2
        static let delayForPerformTableViewAnimation: Int = 10 // ms
        static let commentCellCollapsableTextLineLimit: Int = 4
        static let delayForPerformHighlightAnimation: Int = 500 // ms
        static let delayAfterRecievingUpdatedComments: Int = 500 // ms
        static let delayBeforeReEnablingTableViewAnimation: Int = 200 // ms
        static let delayBeforeTryAgainAfterError: Int = 2000 // ms
        static let delayForPerformTableViewAnimationErrorState: Int = 500 // ms
        static let updateTableViewInstantlyDelay: Int = 50 // ms
        static let performActionDelay: Int = 500 // ms
    }

    var closeTapped = PublishSubject<Void>()

    var shouldShowHeaderView: Bool {
        return viewableMode == .independent
    }

    lazy var title: String = {
        return OWLocalizationManager.shared.localizedString(key: "Replies")
    }()

    fileprivate var _closeCommentThread = PublishSubject<Void>()
    var closeCommentThread: Observable<Void> {
        return _closeCommentThread.asObservable()
    }

    var willDisplayCell = PublishSubject<WillDisplayCellEvent>()

    var tableViewHeight = PublishSubject<CGFloat>()
    fileprivate lazy var tableViewHeightChanged: Observable<CGFloat> = {
        tableViewHeight
            .filter { $0 > 0 }
            .distinctUntilChanged()
            .asObservable()
    }()

    fileprivate var errorsLoadingReplies: [OWCommentId: OWRepliesErrorState] = [:]

    fileprivate var postId: OWPostId {
        return OWManager.manager.postId ?? ""
    }

    fileprivate lazy var spacingBetweenComments: CGFloat = {
        return self.commentThreadData.settings.fullConversationSettings.style.spacing.betweenComments / Metrics.spacingBetweenCommentsDivisor
    }()

    fileprivate let commentThreadData: OWCommentThreadRequiredData

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let commentPresentationDataHelper: OWCommentsPresentationDataHelperProtocol
    fileprivate let viewableMode: OWViewableMode
    fileprivate let _commentThreadData = BehaviorSubject<OWCommentThreadRequiredData?>(value: nil)
    fileprivate var articleUrl: String = ""
    fileprivate let disposeBag = DisposeBag()

    fileprivate let commentThreadViewVMScheduler: SchedulerType = SerialDispatchQueueScheduler(qos: .userInitiated, internalSerialQueueName: "commentThreadViewVMScheduler")

    fileprivate lazy var _isReadOnly = BehaviorSubject<Bool>(value: commentThreadData.article.additionalSettings.readOnlyMode == .enable)
    fileprivate lazy var isReadOnly: Observable<Bool> = {
        return _isReadOnly
            .share(replay: 1)
    }()

    fileprivate var _shouldShowErrorLoadingComments = BehaviorSubject<Bool>(value: false)
    var shouldShowErrorLoadingComments: Observable<Bool> {
        return _shouldShowErrorLoadingComments
            .asObservable()
    }

    fileprivate var _tryAgainAfterError = PublishSubject<OWErrorStateTypes>()
    var tryAgainAfterError: Observable<OWErrorStateTypes> {
        return _tryAgainAfterError
            .asObservable()
    }

    fileprivate var _updateTableViewInstantly = PublishSubject<Void>()
    var updateTableViewInstantly: Observable<Void> {
        return _updateTableViewInstantly
            .delay(.milliseconds(Metrics.updateTableViewInstantlyDelay), scheduler: commentThreadViewVMScheduler)
            .asObservable()
    }

    fileprivate let _serverCommentsLoadingState = BehaviorSubject<OWLoadingState>(value: .loading(triggredBy: .initialLoading))
    fileprivate var serverCommentsLoadingState: Observable<OWLoadingState> {
        _serverCommentsLoadingState
            .asObservable()
    }

    fileprivate lazy var commentCellsOptions: Observable<[OWCommentThreadCellOption]> = {
        return _commentsPresentationData
            .rx_elements()
            .flatMapLatest({ [weak self] commentsPresentationData -> Observable<[OWCommentThreadCellOption]> in
                guard let self = self else { return Observable.never() }
                return Observable.just(self.getCells(for: commentsPresentationData))
            })
            .asObservable()
    }()

    fileprivate lazy var errorCellViewModels: Observable<[OWCommentThreadCellOption]> = {
        return shouldShowErrorLoadingComments
            .filter { $0 }
            .flatMapLatest { [weak self] _ -> Observable<[OWCommentThreadCellOption]> in
                guard let self = self else { return .empty() }
                return Observable.just(self.getErrorStateCell(errorStateType: .loadCommentThreadComments))
            }
            .startWith([])
    }()

    fileprivate lazy var cellsViewModels: Observable<[OWCommentThreadCellOption]> = {
        return Observable.combineLatest(commentCellsOptions,
                                        errorCellViewModels,
                                        serverCommentsLoadingState,
                                        shouldShowErrorLoadingComments)
            .observe(on: commentThreadViewVMScheduler)
            .flatMapLatest({ [weak self] commentCellsOptions, errorCellViewModels, loadingState, shouldShowError -> Observable<[OWCommentThreadCellOption]> in
                guard let self = self else { return Observable.never() }
                if case .loading(let loadingReason) = loadingState, loadingReason != .pullToRefresh {
                    return Observable.just(self.getSkeletonCells())
                } else if (shouldShowError) {
                    return Observable.just(errorCellViewModels)
                } else {
                    return Observable.just(commentCellsOptions)
                }
            })
            .observe(on: MainScheduler.instance)
            .scan([], accumulator: { [weak self] previousCommentThreadCellsOptions, newCommentThreadCellsOptions in
                guard let self = self else { return [] }
                var commentsVmsMapper = [OWCommentId: OWCommentCellViewModeling]()
                var commentThreadActionVmsMapper = [String: OWCommentThreadActionsCellViewModeling]()

                previousCommentThreadCellsOptions.forEach { commentThreadCellOption in
                    switch commentThreadCellOption {
                    case .comment(let commentCellViewModel):
                        guard let commentId = commentCellViewModel.outputs.commentVM.outputs.comment.id else { return }
                        commentsVmsMapper[commentId] = commentCellViewModel
                    case .commentThreadActions(let commentThreadActionCellViewModel):
                        commentThreadActionVmsMapper[commentThreadActionCellViewModel.outputs.id] = commentThreadActionCellViewModel
                    default:
                        break
                    }
                }

                let adjustedNewCommentCellOptions: [OWCommentThreadCellOption] = newCommentThreadCellsOptions.map { commentThreadCellOptions in
                    switch commentThreadCellOptions {
                    case .comment(let viewModel):
                        guard let commentId = viewModel.outputs.commentVM.outputs.comment.id else {
                            return commentThreadCellOptions
                        }
                        if let commentCellVm = commentsVmsMapper[commentId] {
                            let commentVm = commentCellVm.outputs.commentVM
                            let updatedCommentVm = viewModel.outputs.commentVM

                            if (updatedCommentVm.outputs.comment != commentVm.outputs.comment) {
                                commentVm.inputs.update(comment: updatedCommentVm.outputs.comment)
                            }
                            if (updatedCommentVm.outputs.user != commentVm.outputs.user) {
                                commentVm.inputs.update(user: updatedCommentVm.outputs.user)
                            }
                            return OWCommentThreadCellOption.comment(viewModel: commentCellVm)
                        } else {
                            return commentThreadCellOptions
                        }
                    case .commentThreadActions(let viewModel):
                        if let commentThreadActionVm = commentThreadActionVmsMapper[viewModel.outputs.id] {
                            if (ObjectIdentifier(viewModel.outputs.commentPresentationData) != ObjectIdentifier(commentThreadActionVm.outputs.commentPresentationData)) {
                                commentThreadActionVm.inputs.update(commentPresentationData: viewModel.outputs.commentPresentationData)
                            }
                            return OWCommentThreadCellOption.commentThreadActions(viewModel: commentThreadActionVm)
                        } else {
                            return commentThreadCellOptions
                        }
                    default:
                        return commentThreadCellOptions
                    }
                }

                return adjustedNewCommentCellOptions
            })
            .asObservable()
            .share(replay: 1)
    }()

    var _shouldShowError = PublishSubject<Void>()
    var shouldShowError: Observable<Void> {
        return _shouldShowError
            .asObservable()
    }

    var commentThreadDataSourceSections: Observable<[CommentThreadDataSourceModel]> {
        return cellsViewModels
            .map { [weak self] items in
                guard let self = self else { return [] }
                let section = CommentThreadDataSourceModel(model: self.postId, items: items)
                return [section]
            }
    }

    fileprivate var _commentsPresentationData = OWObservableArray<OWCommentPresentationData>()

    var commentCreationTap = PublishSubject<OWCommentCreationTypeInternal>()
    var openCommentCreation: Observable<OWCommentCreationTypeInternal> {
        return commentCreationTap
            .asObservable()
    }

    fileprivate let _updateLocalComment = PublishSubject<(OWComment, OWCommentId)>()
    fileprivate let _replyToLocalComment = PublishSubject<(OWComment, OWCommentId)>()

    fileprivate let _performHighlightAnimationCellIndex = PublishSubject<Int>()
    var scrolledToCellIndex = PublishSubject<Int>()

    var scrollToCellIndex: Observable<Int> {
        _performHighlightAnimationCellIndex
            .asObservable()
    }

    var highlightCellIndex: Observable<Int> {
        return scrolledToCellIndex
            .asObservable()
    }

    fileprivate var _openProfile = PublishSubject<OWOpenProfileType>()
    var openProfile: Observable<OWOpenProfileType> {
        return _openProfile
            .asObservable()
    }

    fileprivate var _urlClick = PublishSubject<URL>()
    var urlClickedOutput: Observable<URL> {
        return _urlClick
            .asObservable()
    }

    fileprivate var deleteComment = PublishSubject<OWCommentViewModeling>()
    fileprivate var muteCommentUser = PublishSubject<OWCommentViewModeling>()

    var viewInitialized = PublishSubject<Void>()
    fileprivate lazy var viewInitializedObservable: Observable<OWLoadingTriggeredReason> = {
        return viewInitialized
            .map { OWLoadingTriggeredReason.initialLoading }
    }()

    var pullToRefresh = PublishSubject<Void>()

    fileprivate var _forceRefresh = PublishSubject<Void>()
    fileprivate lazy var refreshConversationObservable: Observable<OWLoadingTriggeredReason> = {
        return Observable.merge(
            pullToRefresh.map { OWLoadingTriggeredReason.pullToRefresh },
            _forceRefresh.map { OWLoadingTriggeredReason.forceRefresh }
        )
        .withLatestFrom(shouldShowErrorLoadingComments) { ($0, $1) }
        .do(onNext: { [weak self] _, shouldShowErrorLoadingComments in
            // This is for pull to refresh while error state for initial comments is shown
            // We want to show skeletons after this pull to refresh
            if shouldShowErrorLoadingComments {
                guard let self = self else { return }
                self.dataSourceTransition = .reload
                self._serverCommentsLoadingState.onNext(.loading(triggredBy: .tryAgainAfterError))
                self._shouldShowErrorLoadingComments.onNext(false)
                self.servicesProvider.timeMeasuringService().startMeasure(forKey: .commentThreadLoadingInitialComments)
            }
        })
        .map { $0.0 }
        .asObservable()
    }()

    fileprivate var _loadMoreReplies = PublishSubject<OWCommentPresentationData>()

    fileprivate var _performTableViewAnimation = PublishSubject<Void>()
    var performTableViewAnimation: Observable<Void> {
        return _performTableViewAnimation
            .filter { [weak self] in
                return self?.dataSourceTransition ?? .reload == .animated
            }
            .voidify()
            .asObservable()
    }

    var changeThreadOffset = PublishSubject<CGPoint>()
    var threadOffset: Observable<CGPoint> {
        return changeThreadOffset
            .asObservable()
    }

    fileprivate var openReportReasonChange = PublishSubject<OWCommentViewModeling>()
    var openReportReason: Observable<OWCommentViewModeling> {
        return openReportReasonChange
            .asObservable()
    }

    fileprivate var openClarityDetailsChange = PublishSubject<OWClarityDetailsType>()
    var openClarityDetails: Observable<OWClarityDetailsType> {
        return openClarityDetailsChange
            .asObservable()
    }

    var dataSourceTransition: OWViewTransition = .reload

    init (commentThreadData: OWCommentThreadRequiredData,
          servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
          commentPresentationDataHelper: OWCommentsPresentationDataHelperProtocol = OWCommentsPresentationDataHelper(),
          viewableMode: OWViewableMode = .independent) {
        self.servicesProvider = servicesProvider
        self.commentPresentationDataHelper = commentPresentationDataHelper
        self.viewableMode = viewableMode
        self.commentThreadData = commentThreadData
        self._commentThreadData.onNext(commentThreadData)
        self.setupObservers()
    }
}

fileprivate extension OWCommentThreadViewViewModel {
    func getCells(for commentsPresentationData: [OWCommentPresentationData]) -> [OWCommentThreadCellOption] {
        var cellOptions = [OWCommentThreadCellOption]()

        for (idx, commentPresentationData) in commentsPresentationData.enumerated() {
            guard let commentCellVM = self.getCommentCellVm(for: commentPresentationData.id) else { continue }

            if (commentCellVM.outputs.commentVM.outputs.comment.depth == 0 && idx > 0) {
                cellOptions.append(OWCommentThreadCellOption.spacer(viewModel: OWSpacerCellViewModel(
                    id: "\(commentPresentationData.id)_spacer",
                    style: .comment
                )))
            }

            cellOptions.append(OWCommentThreadCellOption.comment(viewModel: commentCellVM))

            let depth = commentCellVM.outputs.commentVM.outputs.comment.depth ?? 0

            let repliesToShowCount = commentPresentationData.repliesPresentation.count

            switch (repliesToShowCount, commentPresentationData.totalRepliesCount) {
            case (_, 0):
                break
            case (0, _):
                if self.errorsLoadingReplies[commentPresentationData.id] != nil {
                    cellOptions.append(OWCommentThreadCellOption.commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel(
                        id: "\(commentPresentationData.id)_collapse",
                        data: commentPresentationData,
                        mode: .collapse,
                        depth: depth,
                        spacing: spacingBetweenComments
                    )))
                } else {
                    cellOptions.append(OWCommentThreadCellOption.commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel(
                        id: "\(commentPresentationData.id)_expand_only",
                        data: commentPresentationData,
                        mode: .expand,
                        depth: depth,
                        spacing: spacingBetweenComments
                    )))
                }
            default:
                cellOptions.append(OWCommentThreadCellOption.commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel(
                    id: "\(commentPresentationData.id)_collapse",
                    data: commentPresentationData,
                    mode: .collapse,
                    depth: depth,
                    spacing: spacingBetweenComments
                )))

                cellOptions.append(contentsOf: getCells(for: commentPresentationData.repliesPresentation))

                if self.errorsLoadingReplies[commentPresentationData.id] == nil,
                   repliesToShowCount < commentPresentationData.totalRepliesCount {
                    // This is expand more replies in root depth
                    cellOptions.append(OWCommentThreadCellOption.commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel(
                        id: "\(commentPresentationData.id)_expand",
                        data: commentPresentationData,
                        mode: .expand,
                        depth: depth,
                        spacing: spacingBetweenComments
                    )))
                }
            }

            if self.errorsLoadingReplies[commentPresentationData.id] == .error {
                let cellOptionsError = self.getErrorStateCell(errorStateType: .loadCommentThreadReplies(commentPresentationData: commentPresentationData), depth: depth)
                cellOptions.append(contentsOf: cellOptionsError)
            }

            if self.errorsLoadingReplies[commentPresentationData.id] == .reloading {
                cellOptions.append(contentsOf: self.getLoadingCell())
            }
        }
        return cellOptions
    }

    func getLoadingCell() -> [OWCommentThreadCellOption] {
        return [OWCommentThreadCellOption.loading(viewModel: OWLoadingCellViewModel())]
    }

    func getErrorStateCell(errorStateType: OWErrorStateTypes, commentPresentationData: OWCommentPresentationData? = nil, depth: Int = 0) -> [OWCommentThreadCellOption] {
        let errorViewModel = OWErrorStateCellViewModel(errorStateType: errorStateType, commentPresentationData: commentPresentationData, depth: depth)
        return [OWCommentThreadCellOption.conversationErrorState(viewModel: errorViewModel)]
    }

    func getSkeletonCells() -> [OWCommentThreadCellOption] {
        var cellOptions = [OWCommentThreadCellOption]()
        let numberOfComments = Metrics.numberOfSkeletonComments
        let skeletonCellVMs = (0 ..< numberOfComments).map { index in
            OWCommentSkeletonShimmeringCellViewModel(depth: index > 0 ? 1 : 0)
        }
        let skeletonCells = skeletonCellVMs.map { OWCommentThreadCellOption.commentSkeletonShimmering(viewModel: $0) }
        cellOptions.append(contentsOf: skeletonCells)

        return cellOptions
    }

    func getCommentsPresentationData(of comments: [OWComment]) -> [OWCommentPresentationData] {
        var commentsPresentationData = [OWCommentPresentationData]()

        for comment in comments {
            guard let commentId = comment.id else { continue }

            let commentPresentationData = OWCommentPresentationData(
                id: commentId,
                repliesIds: comment.replies?.map { $0.id }.unwrap() ?? [],
                totalRepliesCount: comment.repliesCount ?? 0,
                repliesOffset: comment.offset ?? 0,
                repliesPresentation: getCommentsPresentationData(of: comment.replies ?? [])
            )

            commentsPresentationData.append(commentPresentationData)
        }
        return commentsPresentationData
    }

    func getExistingRepliesPresentationData(for commentPresentationData: OWCommentPresentationData) -> [OWCommentPresentationData] {
        var existingRepliesPresentationData: [OWCommentPresentationData] = []
        for replyId in commentPresentationData.repliesIds {
            guard let replyCellVm = self.getCommentCellVm(for: replyId) else { continue }

            let reply = replyCellVm.outputs.commentVM.outputs.comment
            existingRepliesPresentationData.append(
                OWCommentPresentationData(
                    id: replyId,
                    repliesIds: reply.replies?.map { $0.id }.unwrap() ?? [],
                    totalRepliesCount: reply.repliesCount ?? 0,
                    repliesOffset: reply.offset ?? 0,
                    repliesPresentation: []
                )
            )
        }
        return existingRepliesPresentationData
    }

    func getCommentCellVm(for commentId: String) -> OWCommentCellViewModel? {
        guard let comment = self.servicesProvider.commentsService().get(commentId: commentId, postId: self.postId),
              let commentUserId = comment.userId,
              let user = self.servicesProvider.usersService().get(userId: commentUserId)
        else { return nil }

        var replyToUser: SPUser? = nil
        if let replyToCommentId = comment.parentId,
           let replyToComment = self.servicesProvider.commentsService().get(commentId: replyToCommentId, postId: self.postId),
           let replyToUserId = replyToComment.userId {
            replyToUser = self.servicesProvider.usersService().get(userId: replyToUserId)
        }

        let reportedCommentsService = self.servicesProvider.reportedCommentsService()
        let commentWithUpdatedStatus = reportedCommentsService.getUpdatedComment(for: comment, postId: self.postId)

        return OWCommentCellViewModel(data: OWCommentRequiredData(
            comment: commentWithUpdatedStatus,
            user: user,
            replyToUser: replyToUser,
            collapsableTextLineLimit: Metrics.commentCellCollapsableTextLineLimit,
            section: self.commentThreadData.article.additionalSettings.section),
                                      spacing: spacingBetweenComments)
    }

    func cacheConversationRead(response: OWConversationReadRM) {
        if let responseComments = response.conversation?.comments {
            self.servicesProvider.commentsService().set(comments: responseComments, postId: self.postId)
        }
        if let responseUsers = response.conversation?.users {
            self.servicesProvider.usersService().set(users: responseUsers)
        }
        // cache reported comments in reported comments service
        self.servicesProvider.reportedCommentsService().updateReportedComments(forConversationResponse: response, postId: self.postId)
    }

    func performRankChange(for commentVm: OWCommentViewModeling, rankChange: SPRankChange) {
        let comment = commentVm.outputs.comment
        let commentUser = commentVm.outputs.user

        // Do not perform the action if comment is reported or user is muted
        guard !comment.reported && !commentUser.isMuted else { return }

        let currentRankByUser = comment.rank?.rankedByCurrentUser ?? 0
        var rankChangeToPerform: SPRankChange? = nil

        switch (currentRankByUser, rankChange.to.rawValue) {
        case (0, _):
            // If the comment is not currently ranked by user, perform original rank change
            rankChangeToPerform = rankChange
        case (-1, 1):
            // Change from rank
            if let newFromRank = SPRank(rawValue: -1),
               let newToRank = SPRank(rawValue: 1) {
                rankChangeToPerform = SPRankChange(from: newFromRank, to: newToRank)
            }
        case (1, -1):
            // Change from rank
            if let newFromRank = SPRank(rawValue: 1),
               let newToRank = SPRank(rawValue: -1) {
                rankChangeToPerform = SPRankChange(from: newFromRank, to: newToRank)
            }
        default:
            // Should not perform action otherwise
            break
        }

        if let rankChangeToPerform = rankChangeToPerform {
            let selectedCommentVotingVm = commentVm.outputs.commentEngagementVM.outputs.votingVM
            selectedCommentVotingVm.inputs.rankChanged.onNext(rankChangeToPerform)
        }
    }
}

fileprivate extension OWCommentThreadViewViewModel {
    // swiftlint:disable function_body_length
    func setupObservers() {
        servicesProvider.activeArticleService().updateStrategy(commentThreadData.article.articleInformationStrategy)

        closeTapped.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self._closeCommentThread.onNext()
        })
        .disposed(by: disposeBag)

        // Observable for the conversation network API
        let initialConversationThreadReadObservable = _commentThreadData
            .unwrap()
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dataSourceTransition = .reload // Block animations in the table view
            })
            .flatMap { [weak self] data -> Observable<Event<OWConversationReadRM>> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                .netwokAPI()
                .conversation
                .conversationRead(mode: .newest, page: OWPaginationPage.first, childCount: 5, messageId: data.commentId)
                .response
                .materialize()
        }

        // Try again after error loading initial comments
        let tryAgainAfterInitialError = tryAgainAfterError
            .filter { $0 == .loadCommentThreadComments }
            .voidify()
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.dataSourceTransition = .reload
                self._serverCommentsLoadingState.onNext(.loading(triggredBy: .tryAgainAfterError))
                self._shouldShowErrorLoadingComments.onNext(false)
                self.servicesProvider.timeMeasuringService().startMeasure(forKey: .commentThreadLoadingInitialComments)
            })
            .map { return OWLoadingTriggeredReason.tryAgainAfterError }
            .asObservable()

        // Try again after error loading more replies
        let tryAgainAfterLoadingMoreRepliesError = tryAgainAfterError
            .filter {
                if case .loadCommentThreadReplies = $0 { return true }
                return false
            }
            .map { errorState -> OWCommentPresentationData? in
                switch errorState {
                case .loadCommentThreadReplies(commentPresentationData: let commentPresentationData):
                    return commentPresentationData
                default:
                    return nil
                }
            }
            .unwrap()
            .do(onNext: { [weak self] commentPresentationData in
                guard let self = self else { return }
                self.sendEvent(for: .loadMoreRepliesClicked(commentId: commentPresentationData.id))
                if self.errorsLoadingReplies[commentPresentationData.id] == .error {
                    self.errorsLoadingReplies[commentPresentationData.id] = .reloading
                    commentPresentationData.update.onNext()
                }
            })
            .asObservable()

        refreshConversationObservable
            .voidify()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.errorsLoadingReplies.removeAll()
            })
            .disposed(by: disposeBag)

        let commentThreadFetchedObservable = Observable.merge(viewInitializedObservable,
                                                              refreshConversationObservable,
                                                              tryAgainAfterInitialError)
            .withLatestFrom(shouldShowErrorLoadingComments) { ($0, $1) }
            .do(onNext: { [weak self] (loadingTriggeredReason, shouldShowErrorLoadingComments) in
                // This is for pull to refresh while error state for initial comments is shown
                // We want to show skeletons after this pull to refresh
                if shouldShowErrorLoadingComments {
                    guard let self = self else { return }
                    self.dataSourceTransition = .reload
                    self._serverCommentsLoadingState.onNext(.loading(triggredBy: loadingTriggeredReason))
                    self._shouldShowErrorLoadingComments.onNext(false)
                    self.servicesProvider.timeMeasuringService().startMeasure(forKey: .commentThreadLoadingInitialComments)
                }
            })
            .do(onNext: { [weak self] (loadingTriggeredReason, _) in
                guard let self = self else { return }
                self.errorsLoadingReplies.removeAll()
                self._serverCommentsLoadingState.onNext(.loading(triggredBy: loadingTriggeredReason))
            })
            .flatMapLatest { _ -> Observable<Event<OWConversationReadRM>> in
                return initialConversationThreadReadObservable
            }
            .flatMapLatest({ [weak self] event -> Observable<(Event<OWConversationReadRM>)> in
                // Add delay if end time for load initial comments is less then delayBeforeTryAgainAfterError
                guard let self = self else { return .empty() }
                let timeToLoadInitialComments = self.timeMeasuringMilliseconds(forKey: .commentThreadLoadingInitialComments)
                if case .error = event,
                   timeToLoadInitialComments < Metrics.delayBeforeTryAgainAfterError {
                    return Observable.just((event))
                        .delay(.milliseconds(Metrics.delayBeforeTryAgainAfterError - timeToLoadInitialComments), scheduler: self.commentThreadViewVMScheduler)
                }
                return Observable.just((event))
            })
            .map { [weak self] event -> OWConversationReadRM? in
                guard let self = self else { return nil }
                switch event {
                case .next(let conversationRead):
                    // TODO: Clear any RX variables which affect error state in the View layer (like _shouldShowError).
                    self._shouldShowErrorLoadingComments.onNext(false)
                    return conversationRead
                case .error(_):
                    // TODO: handle error - update the UI state for showing error in the View layer
                    self._serverCommentsLoadingState.onNext(.notLoading)
                    self._shouldShowErrorLoadingComments.onNext(true)
                    return nil
                default:
                    return nil
                }
            }
            .unwrap()
            .share()

        // Set read only mode
        commentThreadFetchedObservable
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                var isReadOnly: Bool = response.conversation?.readOnly ?? false
                switch self.commentThreadData.article.additionalSettings.readOnlyMode {
                case .disable:
                    isReadOnly = false
                case .enable:
                    isReadOnly = true
                case .server:
                    break
                }
                self._isReadOnly.onNext(isReadOnly)
            })
            .disposed(by: disposeBag)

        // first load comments or refresh comments
        commentThreadFetchedObservable
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }

                // Should not be empty
                guard let comments = response.conversation?.comments,
                      !comments.isEmpty else {
                    self._serverCommentsLoadingState.onNext(.notLoading)
                    self._shouldShowErrorLoadingComments.onNext(true)
                    return
                }

                self.cacheConversationRead(response: response)

                if let responseComments = response.conversation?.comments {
                    let commentsPresentationData = self.getCommentsPresentationData(of: responseComments)

                    self._commentsPresentationData.replaceAll(with: commentsPresentationData)

                    // Update loading state only after the presented comments are updated
                    self._serverCommentsLoadingState.onNext(.notLoading)

                    self._updateTableViewInstantly.onNext()
                }
            })
            .disposed(by: disposeBag)

        // Re-enabling animations in the comment thread table view
        commentThreadFetchedObservable
            .delay(.milliseconds(Metrics.delayBeforeReEnablingTableViewAnimation), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dataSourceTransition = .animated
            })
            .disposed(by: disposeBag)

        let loadMoreRepliesReadObservable = Observable.merge(_loadMoreReplies, tryAgainAfterLoadingMoreRepliesError)
            .flatMap { [weak self] commentPresentationData -> Observable<(OWCommentPresentationData, Event<OWConversationReadRM>?)> in
                guard let self = self else { return .empty() }

                let hasRepliesError = self.errorsLoadingReplies[commentPresentationData.id] != nil
                let commentPresentationRepliesCount = hasRepliesError ? 0 : commentPresentationData.repliesPresentation.count

                let countAfterUpdate = min(commentPresentationRepliesCount + Metrics.defaultNumberOfReplies, commentPresentationData.totalRepliesCount)
                let repliesIdsCount = hasRepliesError ? 0 : commentPresentationData.repliesIds.count
                if countAfterUpdate <= repliesIdsCount {
                    // no need to fetch more comments
                    return Observable.just((commentPresentationData, nil))
                }

                let fetchCount = countAfterUpdate - repliesIdsCount

                self.servicesProvider.timeMeasuringService().startMeasure(forKey: .commentThreadLoadingMoreReplies(commentId: commentPresentationData.id))

                return self.servicesProvider
                    .netwokAPI()
                    .conversation
                    .conversationRead(mode: .best, page: .next, count: fetchCount, parentId: commentPresentationData.id, offset: commentPresentationData.repliesOffset)
                    .response
                    .materialize()
                    .map { (commentPresentationData, $0) }
            }

        let loadMoreRepliesReadUpdated = loadMoreRepliesReadObservable
            .do(onNext: { [weak self] (commentPresentationData, _) in
                guard let self = self else { return }
                self.errorsLoadingReplies.removeValue(forKey: commentPresentationData.id)
            })
            .flatMapLatest({ [weak self] (commentPresentationData, event) -> Observable<(OWCommentPresentationData, Event<OWConversationReadRM>?)> in
                // Add delay if end time for load more replies is less then delayBeforeTryAgainAfterError
                guard let self = self else { return Observable.just((commentPresentationData, event)) }
                let timeToLoadMoreReplies = self.timeMeasuringMilliseconds(forKey: .commentThreadLoadingMoreReplies(commentId: commentPresentationData.id))
                if case .error = event,
                   timeToLoadMoreReplies < Metrics.delayBeforeTryAgainAfterError {
                    return Observable.just((commentPresentationData, event))
                        .delay(.milliseconds(Metrics.delayBeforeTryAgainAfterError - timeToLoadMoreReplies), scheduler: self.commentThreadViewVMScheduler)
                }
                return Observable.just((commentPresentationData, event))
            })
            .map { (commentPresentationData, event) -> (OWCommentPresentationData, OWConversationReadRM?, Bool)? in
                guard event != nil else {
                    // We didn't have to fetch new data - the event is nil
                    return (commentPresentationData, nil, false)
                }

                switch event {
                case .next(let conversationRead):
                    // TODO: Clear any RX variables which affect error state in the View layer (like _shouldShowError).
                    return (commentPresentationData, conversationRead, false)
                case .error(_):
                    // TODO: handle error - update the UI state for showing error in the View layer
                    return (commentPresentationData, nil, true)
                default:
                    return nil
                }
            }
            .unwrap()

        loadMoreRepliesReadUpdated
            .subscribe(onNext: { [weak self] (commentPresentationData, response, shouldShowErrorLoadingReplies) in
                guard let self = self else { return }
                if shouldShowErrorLoadingReplies {
                    self.errorsLoadingReplies[commentPresentationData.id] = .error
                    commentPresentationData.update.onNext()
                } else {
                    let existingRepliesPresentationData = self.getExistingRepliesPresentationData(for: commentPresentationData)

                    // add presentation data from response
                    var presentationDataFromResponse: [OWCommentPresentationData] = []
                    if let response = response {
                        self.cacheConversationRead(response: response)

                        if let responseComments = response.conversation?.comments {
                            presentationDataFromResponse = self.getCommentsPresentationData(of: responseComments)
                        }

                        // filter existing comments
                        presentationDataFromResponse = presentationDataFromResponse.filter { !commentPresentationData.repliesIds.contains($0.id) }

                        // filter existing reply ids
                        let newRepliesIds = (response.conversation?.comments?.map { $0.id }.unwrap())?.filter { !commentPresentationData.repliesIds.contains($0) }

                        // update commentPresentationData according to the response
                        commentPresentationData.repliesIds.append(contentsOf: newRepliesIds ?? [])
                        commentPresentationData.repliesOffset = response.conversation?.offset ?? 0
                    }

                    var repliesPresentation = existingRepliesPresentationData + presentationDataFromResponse

                    // take required count of replies
                    let countAfterUpdate = min(commentPresentationData.repliesPresentation.count + 5, commentPresentationData.totalRepliesCount)
                    repliesPresentation = Array(repliesPresentation.prefix(countAfterUpdate))

                    commentPresentationData.setRepliesPresentation(repliesPresentation)
                    commentPresentationData.update.onNext()
                }
            })
            .disposed(by: disposeBag)

        // Responding to comment height change (for updating cell)
        cellsViewModels
            .flatMapLatest { cellsVms -> Observable<Void> in
                let sizeChangeObservable: [Observable<Void>] = cellsVms.map { vm in
                    if case.comment(let commentCellViewModel) = vm {
                        let commentVM = commentCellViewModel.outputs.commentVM
                        return commentVM.outputs.heightChanged
                    } else {
                        return nil
                    }
                }
                .unwrap()
                return Observable.merge(sizeChangeObservable)
            }
            .delay(.milliseconds(Metrics.delayForPerformTableViewAnimation), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                self?._performTableViewAnimation.onNext()
            })
            .disposed(by: disposeBag)

        // Responding to errorState cell with tableViewHeight change
        Observable.combineLatest(cellsViewModels, tableViewHeightChanged)
            .flatMapLatest { (cellsVms, tableViewHeight) -> Observable<Void> in
                let sizeChangeObservable: [Observable<Void>] = cellsVms.map { cellVM in
                    if case.conversationErrorState(let errorStateCellViewModeling) = cellVM {
                        let errorStateVM = errorStateCellViewModeling.outputs.errorStateViewModel
                        if errorStateVM.outputs.errorStateType == .loadCommentThreadComments {
                            errorStateVM.inputs.heightChange.onNext(tableViewHeight)
                            return errorStateVM.outputs.height
                                .voidify()
                        }
                    }
                    return nil
                }
                .unwrap()
                return Observable.merge(sizeChangeObservable)
            }
            .delay(.milliseconds(Metrics.delayForPerformTableViewAnimationErrorState), scheduler: commentThreadViewVMScheduler)
            .bind(to: _performTableViewAnimation)
            .disposed(by: disposeBag)

        // Responding to error states try again tap
        cellsViewModels
            .flatMapLatest { cellsVms -> Observable<OWErrorStateTypes> in
                let errorStateTryAgainTapped: [Observable<OWErrorStateTypes>] = cellsVms.map { vm in
                    if case .conversationErrorState(let errorStateCellVM) = vm {
                        let errorStateViewVM = errorStateCellVM.outputs.errorStateViewModel
                        return errorStateViewVM.outputs.tryAgainTapped
                    }
                    return nil
                }
                .unwrap()
                return Observable.merge(errorStateTryAgainTapped)
            }
            .bind(to: _tryAgainAfterError)
            .disposed(by: disposeBag)

        // Observable of the comment cell VMs
        let commentCellsVmsObservable: Observable<[OWCommentCellViewModeling]> = cellsViewModels
            .flatMapLatest { viewModels -> Observable<[OWCommentCellViewModeling]> in
                let commentCellsVms: [OWCommentCellViewModeling] = viewModels.map { vm in
                    if case.comment(let commentCellViewModel) = vm {
                        return commentCellViewModel
                    } else {
                        return nil
                    }
                }
                .unwrap()

                 return Observable.just(commentCellsVms)
            }
            .share(replay: 1)

        // Responding to comments which are just reported
        let reportService = servicesProvider.reportedCommentsService()
        reportService.commentJustReported
            .withLatestFrom(commentCellsVmsObservable) {
                ($0, $1)
            }
            .flatMap { commentId, commentCellVMs -> Observable<(OWCommentId, OWCommentViewModeling)> in
                // 1. Find if such comment VM exist for this comment ID
                guard let commentCellVM = commentCellVMs.first(where: { $0.outputs.commentVM.outputs.comment.id == commentId }) else {
                    return .empty()
                }
                return Observable.just((commentId, commentCellVM.outputs.commentVM))
            }
            .map { [weak self] commentId, commentVm -> (OWComment, OWCommentViewModeling)? in
                // 2. Get updated comment from comments service
                guard let self = self else { return nil }
                if let updatedComment = self.servicesProvider
                    .commentsService()
                    .get(commentId: commentId, postId: self.postId) {
                    return (updatedComment, commentVm)
                } else {
                    return nil
                }
            }
            .unwrap()
            .observe(on: MainScheduler.instance)
            .do(onNext: { comment, commentVM in
                // 3. Update report locally
                commentVM.inputs.update(comment: comment)
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                // 4. Update table view
                self._performTableViewAnimation.onNext()
            })
            .disposed(by: disposeBag)

        // Responding to reply click from comment cells VMs
        commentCellsVmsObservable
            .flatMapLatest { commentCellsVms -> Observable<OWComment> in
                let replyClickOutputObservable: [Observable<OWComment>] = commentCellsVms.map { commentCellVm in
                    let commentVM = commentCellVm.outputs.commentVM
                    return commentVM.outputs.commentEngagementVM
                        .outputs.replyClickedOutput
                        .map { commentVM.outputs.comment }
                }
                return Observable.merge(replyClickOutputObservable)
            }
            .do(onNext: { [weak self] comment in
                self?.sendEvent(for: .replyClicked(replyToCommentId: comment.id ?? ""))
            })
            .subscribe(onNext: { [weak self] comment in
                guard let self = self else { return }
                self.commentCreationTap.onNext(.replyToComment(originComment: comment))
            })
            .disposed(by: disposeBag)

        // Responding to share url from comment cells VMs
        commentCellsVmsObservable
            .flatMapLatest { commentCellsVms -> Observable<(URL, OWCommentViewModeling)> in
                let shareClickOutputObservable: [Observable<(URL, OWCommentViewModeling)>] = commentCellsVms.map { commentCellVm in
                    let commentVM = commentCellVm.outputs.commentVM
                    return commentVM.outputs.commentEngagementVM
                        .outputs.shareCommentUrl
                        .map { ($0, commentVM) }
                }
                return Observable.merge(shareClickOutputObservable)
            }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _, commentVm in
                self?.sendEvent(for: .commentShareClicked(commentId: commentVm.outputs.comment.id ?? ""))
            })
            .flatMap { [weak self] shareUrl, _ -> Observable<OWRxPresenterResponseType> in
                guard let self = self else { return .empty() }
                return self.servicesProvider.presenterService()
                    .showActivity(activityItems: [shareUrl], applicationActivities: nil, viewableMode: self.viewableMode)

            }
            .subscribe { result in
                switch result {
                case .completion:
                    // Do nothing
                    break
                case .selected:
                    // Do nothing
                    break
                }
            }
            .disposed(by: disposeBag)

        // Update comments cells on ReadOnly mode
        Observable.combineLatest(commentCellsVmsObservable, isReadOnly) { commentCellsVms, isReadOnly -> ([OWCommentCellViewModeling], Bool) in
            return (commentCellsVms, isReadOnly)
        }
        .subscribe(onNext: { commentCellsVms, isReadOnly in
            commentCellsVms.forEach {
                $0.outputs.commentVM
                .outputs.commentEngagementVM
                .inputs.isReadOnly
                .onNext(isReadOnly)
            }
        })
        .disposed(by: disposeBag)

        // Observable of the comment action cell VMs
        let commentThreadActionsCellsVmsObservable: Observable<[OWCommentThreadActionsCellViewModeling]> = cellsViewModels
            .flatMapLatest { viewModels -> Observable<[OWCommentThreadActionsCellViewModeling]> in
                let commentThreadActionsCellsVms: [OWCommentThreadActionsCellViewModeling] = viewModels.map { vm in
                    if case.commentThreadActions(let commentThreadActionsCellViewModel) = vm {
                        return commentThreadActionsCellViewModel
                    } else {
                        return nil
                    }
                }
                    .unwrap()
                return Observable.just(commentThreadActionsCellsVms)
            }
            .share()

        // responding to thread action clicked
        commentThreadActionsCellsVmsObservable
            .flatMapLatest { commentThreadActionsCellsVms -> Observable<(OWCommentPresentationData, OWCommentThreadActionsCellMode)> in
                let threadActionsClickObservable = commentThreadActionsCellsVms.map { commentThreadActionsCellsVm in
                    return commentThreadActionsCellsVm.outputs.commentActionsVM
                        .outputs.tapOutput
                        .map { (commentThreadActionsCellsVm.outputs.commentPresentationData, commentThreadActionsCellsVm.outputs.mode) }
                }
                return Observable.merge(threadActionsClickObservable)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] commentPresentationData, mode in
                guard let self = self else { return }
                switch mode {
                case .collapse:
                    self.sendEvent(for: .hideMoreRepliesClicked(commentId: commentPresentationData.id))
                    self.errorsLoadingReplies.removeValue(forKey: commentPresentationData.id)
                    commentPresentationData.setRepliesPresentation([])
                    commentPresentationData.update.onNext()
                case .expand:
                    self.sendEvent(for: .loadMoreRepliesClicked(commentId: commentPresentationData.id))
                    self._loadMoreReplies.onNext(commentPresentationData)
                }

            })
            .disposed(by: disposeBag)

        // Responding to comment avatar and user name tapped
        commentCellsVmsObservable
            .flatMapLatest { commentCellsVms -> Observable<OWOpenProfileType> in
                let avatarClickOutputObservable: [Observable<OWOpenProfileType>] = commentCellsVms.map { commentCellVm in
                    let avatarVM = commentCellVm.outputs.commentVM.outputs.commentHeaderVM.outputs.avatarVM
                    let commentHeaderVM = commentCellVm.outputs.commentVM.outputs.commentHeaderVM
                    return Observable.merge(avatarVM.outputs.openProfile, commentHeaderVM.outputs.openProfile)
                }
                return Observable.merge(avatarClickOutputObservable)
            }
            .do(onNext: { [weak self] openProfileType in
                guard let self = self  else { return }
                let profileType: OWUserProfileType
                let userId: String
                switch openProfileType {
                case .OWProfile(let data):
                    profileType = data.userProfileType
                    userId = data.userId
                case .publisherProfile(let ssoPublisherId, let type):
                    profileType = type
                    userId = ssoPublisherId
                }
                switch profileType {
                case .currentUser: self.sendEvent(for: .myProfileClicked(source: .comment))
                case .otherUser: self.sendEvent(for: .userProfileClicked(userId: userId))
                }
            })
            .bind(to: _openProfile)
            .disposed(by: disposeBag)

        // Subscribe to URL click in comment text
        commentCellsVmsObservable
            .flatMapLatest { commentCellsVms -> Observable<URL> in
                let urlClickObservable: [Observable<URL>] = commentCellsVms.map { commentCellVm -> Observable<URL> in
                    let commentTextVm = commentCellVm.outputs.commentVM.outputs.contentVM.outputs.collapsableLabelViewModel

                    return commentTextVm.outputs.urlClickedOutput
                }
                return Observable.merge(urlClickObservable)
            }
            .subscribe(onNext: { [weak self] url in
                self?._urlClick.onNext(url)
            })
            .disposed(by: disposeBag)

        // Observe on rank click
        let userTryingToChangeRankObservable = commentCellsVmsObservable
            .flatMap { commentCellsVms -> Observable<(OWCommentViewModeling, SPRankChange)> in
                let rankClickObservable: [Observable<(OWCommentViewModeling, SPRankChange)>] = commentCellsVms.map { commentCellVm -> Observable<(OWCommentViewModeling, SPRankChange)> in
                    let commentVm = commentCellVm.outputs.commentVM
                    let commentRankVm = commentVm.outputs.commentEngagementVM.outputs.votingVM

                    return commentRankVm.outputs.rankChangeTriggered
                        .map { (commentVm, $0) }
                }
                return Observable.merge(rankClickObservable)
            }
            .flatMapLatest { [weak self] commentVm, rankChange -> Observable<(OWCommentViewModeling, SPRankChange)> in
                // 1. Triggering authentication UI if needed
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().ifNeededTriggerAuthenticationUI(for: .votingComment)
                    .map { _ in (commentVm, rankChange) }
            }
            .flatMapLatest { [weak self] commentVm, rankChange -> Observable<(OWCommentViewModeling, SPRankChange)?> in
                // 2. Waiting for authentication required for voting
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().waitForAuthentication(for: .votingComment)
                    .map { $0 ? (commentVm, rankChange) : nil }
            }
            .unwrap()

        userTryingToChangeRankObservable
            .do(onNext: { [weak self] commentVm, rankChange in
                guard let self = self,
                      let commentId = commentVm.outputs.comment.id,
                      let eventType = rankChange.analyticsEventType(commentId: commentId)
                else { return }
                self.sendEvent(for: eventType)
            })
            .subscribe(onNext: { commentVm, rankChange in
                let commentRankVm = commentVm.outputs.commentEngagementVM.outputs.votingVM
                commentRankVm.inputs.rankChanged.onNext(rankChange)
            })
            .disposed(by: disposeBag)

        // Observe on read more click
        commentCellsVmsObservable
            .flatMap { commentCellsVms -> Observable<OWCommentId> in
                let readMoreClickObservable: [Observable<OWCommentId>] = commentCellsVms.map { commentCellVm -> Observable<OWCommentId> in
                    let commentTextVm = commentCellVm.outputs.commentVM.outputs.contentVM.outputs.collapsableLabelViewModel

                    return commentTextVm.outputs.readMoreTap
                        .map { commentCellVm.outputs.commentVM.outputs.comment.id ?? "" }
                }
                return Observable.merge(readMoreClickObservable)
            }
            .subscribe(onNext: { [weak self] commentId in
                self?.sendEvent(for: .commentReadMoreClicked(commentId: commentId))
            })
            .disposed(by: disposeBag)

        let selectedCommentCellVm = commentCellsVmsObservable
            .map { [weak self] commentCellsVms -> OWCommentCellViewModeling? in
                guard let self = self else { return nil }
                let selectedCommentCellVm: OWCommentCellViewModeling? = commentCellsVms.first { vm in
                        return vm.outputs.id == self.commentThreadData.commentId
                }
                return selectedCommentCellVm
            }
            .unwrap()
            .share()

        let selectedCommentCellVmIndex = cellsViewModels
            .map { [weak self] cellsViewModels -> Int? in
                guard let self = self else { return nil }
                let commentIndex: Int? = cellsViewModels.firstIndex { vm in
                    if case .comment(let commentCellViewModel) = vm {
                        return commentCellViewModel.outputs.id == self.commentThreadData.commentId
                    } else {
                        return false
                    }
                }
                return commentIndex
            }
            .unwrap()
            .share()

        // perform highlight animation for selected comment id
        selectedCommentCellVmIndex
            .delay(.milliseconds(Metrics.delayForPerformHighlightAnimation), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .take(1)
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self.dataSourceTransition = .reload
                self._performHighlightAnimationCellIndex.onNext(index)
            })
            .disposed(by: disposeBag)

        // error alert
        shouldShowError
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let actions = [OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "OK"), type: OWEmptyMenu.ok)]
                self.servicesProvider.presenterService()
                    .showAlert(
                        title: OWLocalizationManager.shared.localizedString(key: "ConnectivityErrorMessage"),
                        message: "",
                        actions: actions,
                        viewableMode: self.viewableMode
                    )
                    .subscribe(onNext: { result in
                        switch result {
                        case .completion:
                            // Do nothing
                            break
                        case .selected:
                            // TODO: handle selection
                            break
                        }
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)

        // Open menu for comment and handle actions
        commentCellsVmsObservable
            .flatMapLatest { commentCellsVms -> Observable<([OWRxPresenterAction], OWUISource, OWCommentViewModeling)> in
                let openMenuClickObservable = commentCellsVms.map { commentCellVm -> Observable<([OWRxPresenterAction], OWUISource, OWCommentViewModeling)> in
                    let commentVm = commentCellVm.outputs.commentVM
                    let commentHeaderVm = commentVm.outputs.commentHeaderVM

                    return commentHeaderVm.outputs.openMenu
                        .map { ($0.0, $0.1, commentVm) }
                }
                return Observable.merge(openMenuClickObservable)
            }
            .do(onNext: { [weak self] (_, _, commentVm) in
                self?.sendEvent(for: .commentMenuClicked(commentId: commentVm.outputs.comment.id ?? ""))
            })
            .observe(on: MainScheduler.instance)
            .flatMapLatest { [weak self] (actions, sender, commentVm) -> Observable<(OWRxPresenterResponseType, OWCommentViewModeling)> in
                guard let self = self else { return .empty()}
                return self.servicesProvider.presenterService()
                    .showMenu(actions: actions, sender: sender, viewableMode: self.viewableMode)
                    .map { ($0, commentVm) }
            }
            .subscribe(onNext: { [weak self] result, commentVm in
                guard let self = self else { return }
                switch result {
                case .completion:
                    self.sendEvent(for: .commentMenuClosed(commentId: commentVm.outputs.comment.id ?? ""))
                case .selected(action: let action):
                    switch (action.type) {
                    case OWCommentOptionsMenu.reportComment:
                        self.sendEvent(for: .commentMenuReportClicked(commentId: commentVm.outputs.comment.id ?? ""))
                        self.openReportReasonChange.onNext(commentVm)
                    case OWCommentOptionsMenu.deleteComment:
                        self.sendEvent(for: .commentMenuDeleteClicked(commentId: commentVm.outputs.comment.id ?? ""))
                        self.deleteComment.onNext(commentVm)
                    case OWCommentOptionsMenu.editComment:
                        self.sendEvent(for: .commentMenuEditClicked(commentId: commentVm.outputs.comment.id ?? ""))
                        self.commentCreationTap.onNext(.edit(comment: commentVm.outputs.comment))
                    case OWCommentOptionsMenu.muteUser:
                        self.sendEvent(for: .commentMenuMuteClicked(commentId: commentVm.outputs.comment.id ?? ""))
                        self.muteCommentUser.onNext(commentVm)
                    default:
                        return
                    }
                }
            })
            .disposed(by: disposeBag)

        // Observe open clarity details
        commentCellsVmsObservable
            .flatMapLatest { commentCellsVms -> Observable<OWClarityDetailsType> in
                let learnMoreClickObservable: [Observable<OWClarityDetailsType>] = commentCellsVms.map { commentCellVm -> Observable<OWClarityDetailsType> in
                    let commentStatusVm = commentCellVm.outputs.commentVM.outputs.commentStatusVM
                    return commentStatusVm.outputs.learnMoreClicked
                }
                return Observable.merge(learnMoreClickObservable)
            }
            .subscribe(onNext: { [weak self] clarityDetailsType in
                self?.openClarityDetailsChange.onNext(clarityDetailsType)
            })
            .disposed(by: disposeBag)

        // Observe on read more click
        commentCellsVmsObservable
            .flatMap { commentCellsVms -> Observable<OWCommentId> in
                let readMoreClickObservable: [Observable<OWCommentId>] = commentCellsVms.map { commentCellVm -> Observable<OWCommentId> in
                    let commentTextVm = commentCellVm.outputs.commentVM.outputs.contentVM.outputs.collapsableLabelViewModel

                    return commentTextVm.outputs.readMoreTap
                        .map { commentCellVm.outputs.commentVM.outputs.comment.id ?? "" }
                }
                return Observable.merge(readMoreClickObservable)
            }
            .subscribe(onNext: { [weak self] commentId in
                self?.sendEvent(for: .commentReadMoreClicked(commentId: commentId))
            })
            .disposed(by: disposeBag)

        let commentDeletedLocallyObservable = deleteComment
            .asObservable()
            .flatMap { [weak self] commentVm -> Observable<(OWRxPresenterResponseType, OWCommentViewModeling)> in
                guard let self = self else { return .empty() }
                let actions = [
                    OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "Delete"), type: OWCommentDeleteAlert.delete, style: .destructive),
                    OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "Cancel"), type: OWCommentDeleteAlert.cancel, style: .cancel)
                ]
                return self.servicesProvider.presenterService()
                    .showAlert(
                        title: OWLocalizationManager.shared.localizedString(key: "DeleteCommentTitle"),
                        message: OWLocalizationManager.shared.localizedString(key: "DeleteCommentMessage"),
                        actions: actions,
                        viewableMode: self.viewableMode
                    ).map { ($0, commentVm) }
            }
            .map { [weak self] result, commentVm -> Bool in
                guard let self = self else { return false }
                switch result {
                case .completion:
                    return false
                case .selected(let action):
                    switch action.type {
                    case OWCommentDeleteAlert.delete:
                        self.sendEvent(for: .commentMenuConfirmDeleteClicked(commentId: commentVm.outputs.comment.id ?? ""))
                        return true
                    default:
                        return false
                    }
                }
            }
            .filter { $0 }
            .withLatestFrom(deleteComment)
            .map { commentVm -> (OWCommentViewModeling, OWComment) in
                var updatedComment = commentVm.outputs.comment
                updatedComment.setIsDeleted(true)
                return (commentVm, updatedComment)
            }
            .do(onNext: { [weak self] _, updatedComment in
                guard let self = self else { return }
                self.servicesProvider
                    .commentsService()
                    .set(comments: [updatedComment], postId: self.postId)
            })
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] commentVm, updatedComment in
                guard let self = self else { return }
                commentVm.inputs.update(comment: updatedComment)
                self._performTableViewAnimation.onNext()
            })
            .map { $0.0 }

        // Deleting comment from network
        commentDeletedLocallyObservable
            .observe(on: MainScheduler.asyncInstance)
            .flatMap { [weak self] commentVm -> Observable<Event<OWCommentDelete>> in
                let comment = commentVm.outputs.comment
                guard let self = self,
                      let commentId = comment.id
                else { return .empty() }
                return self.servicesProvider
                    .netwokAPI()
                    .conversation
                    .commentDelete(id: commentId, parentId: comment.parentId)
                    .response
                    .materialize()
            }
            .map { event -> OWCommentDelete? in
                switch event {
                case .next(let commentDelete):
                    // TODO: Clear any RX variables which affect error state in the View layer (like _shouldShowError).
                    return commentDelete
                case .error(_):
                    // TODO: handle error - update something like _shouldShowError RX variable which affect the UI state for showing error in the View layer
                    return nil
                default:
                    return nil
                }
            }
            .unwrap()
            .subscribe(onNext: { _ in
                // successfully deleted
            })
            .disposed(by: disposeBag)

        let muteUserConfirmationObservable = muteCommentUser
            .asObservable()
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                // 1. Triggering authentication UI if needed
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().ifNeededTriggerAuthenticationUI(for: .mutingUser)
            }
            .flatMapLatest { [weak self] neededToAuthenticate -> Observable<(Bool, Bool)> in
                // 2. Waiting for authentication required for muting user
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().waitForAuthentication(for: .mutingUser)
                    .map { (neededToAuthenticate, $0) }
            }
            .filter { $0.1 }
            .map { $0.0 && $0.1 }
            .flatMapLatest { [weak self] needToRefreshConversation -> Observable<(Bool, OWRxPresenterResponseType)> in
                // 3. Show alert
                guard let self = self else { return .empty() }
                let actions = [
                    OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "Mute"), type: OWCommentUserMuteAlert.mute, style: .destructive),
                    OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "Cancel"), type: OWCommentUserMuteAlert.cancel, style: .cancel)
                ]
                return self.servicesProvider.presenterService()
                    .showAlert(
                        title: OWLocalizationManager.shared.localizedString(key: "MuteUser"),
                        message: OWLocalizationManager.shared.localizedString(key: "MuteUserMessage"),
                        actions: actions,
                        viewableMode: self.viewableMode
                    )
                    .map { (needToRefreshConversation, $0) }
            }

        let muteUserObservable = muteUserConfirmationObservable
            .map { needToRefreshConversation, result -> (Bool, Bool) in
                // 4. Handle alert result
                switch result {
                case .completion:
                    return (false, false)
                case .selected(let action):
                    switch action.type {
                    case OWCommentUserMuteAlert.mute:
                        return (needToRefreshConversation, true)
                    default:
                        return (needToRefreshConversation, false)
                    }
                }
            }
            .do(onNext: { [weak self] needToRefreshConversation, _ in
                // 5. Refresh conversation in case user logged in
                guard let self = self else { return }
                if needToRefreshConversation {
                    self._serverCommentsLoadingState.onNext(.loading(triggredBy: .forceRefresh))
                    self.servicesProvider.conversationUpdaterService().update(.refreshConversation, postId: self.postId)
                }
            })
            .flatMapLatest { [weak self] needToRefreshConversation, shouldMute -> Observable<Bool> in
                // 6. Wait for conversation to refresh in case user logged in
                guard let self = self else { return .empty() }
                if needToRefreshConversation {
                    return self.serverCommentsLoadingState
                        .filter { $0 == .notLoading }
                        .take(1)
                        .delay(.milliseconds(Metrics.delayAfterRecievingUpdatedComments), scheduler: self.commentThreadViewVMScheduler)
                        .map { _ in shouldMute }
                } else {
                    return Observable.just(shouldMute)
                }
            }
            .filter { $0 }
            .withLatestFrom(muteCommentUser)
            .map { $0.outputs.comment.userId }
            .unwrap()
            .share()

        self.servicesProvider.conversationUpdaterService()
            .getConversationUpdates(for: postId)
            .flatMap { updateType -> Observable<OWConversationUpdateType> in
                // Making sure comment cells are visible
                return commentCellsVmsObservable
                    .filter { !$0.isEmpty }
                    .take(1)
                    .map { _ in updateType }
            }
            .delay(.milliseconds(Metrics.delayAfterRecievingUpdatedComments), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] updateType in
                guard let self = self else { return }
                switch updateType {
                case .insert:
                    // Not relevant in comment thread
                    break
                case let .update(commentId, withComment):
                    self._updateLocalComment.onNext((withComment, commentId))
                case let .insertReply(comment, toCommentId):
                    self._replyToLocalComment.onNext((comment, toCommentId))
                case .refreshConversation:
                    self.dataSourceTransition = .reload
                    self._forceRefresh.onNext()
                }
            })
            .disposed(by: disposeBag)

        _updateLocalComment
            .withLatestFrom(commentCellsVmsObservable) { ($0.0, $0.1, $1) }
            .do(onNext: { [weak self] comment, _, _ in
                guard let self = self else { return }
                self.servicesProvider
                    .commentsService()
                    .set(comments: [comment], postId: self.postId)
            })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] comment, commentId, commentCellsVms in
                guard let self = self else { return }
                if let commentCellVm = commentCellsVms.first(where: { $0.outputs.commentVM.outputs.comment.id == commentId }) {
                    commentCellVm.outputs.commentVM.inputs.update(comment: comment)
                    self._performTableViewAnimation.onNext()
                }
            })
            .disposed(by: disposeBag)

        _replyToLocalComment
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] comment, parentCommentId in
                guard let self = self,
                      let commentId = comment.id,
                      let parentCommentPresentationData = self.commentPresentationDataHelper.findVisibleCommentPresentationData(
                        with: parentCommentId,
                        in: Array(self._commentsPresentationData)
                      )
                else { return }
                guard self.commentPresentationDataHelper.findVisibleCommentPresentationData(with: commentId, in: Array(self._commentsPresentationData)) == nil else {
                    // making sure we are not adding an existing reply
                    return
                }
                let newCommentPresentationData = OWCommentPresentationData(id: commentId)
                let existingRepliesPresentationData: [OWCommentPresentationData]
                if (parentCommentPresentationData.repliesPresentation.count == 0) {
                    existingRepliesPresentationData = Array(self.getExistingRepliesPresentationData(for: parentCommentPresentationData).prefix(4))
                } else {
                    existingRepliesPresentationData = parentCommentPresentationData.repliesPresentation
                }
                parentCommentPresentationData.repliesIds.insert(commentId, at: 0)
                parentCommentPresentationData.setTotalRepliesCount(parentCommentPresentationData.totalRepliesCount + 1)
                parentCommentPresentationData.setRepliesPresentation([newCommentPresentationData] + existingRepliesPresentationData)
                parentCommentPresentationData.update.onNext()
            })
            .disposed(by: disposeBag)

        // Handling mute user from network
        muteUserObservable
            .flatMap { [weak self] userId -> Observable<Event<EmptyDecodable>> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                    .netwokAPI()
                    .user
                    .mute(userId: userId)
                    .response
                    .materialize()
            }
            .map { event -> Bool in
                switch event {
                case .next:
                    // TODO: Clear any RX variables which affect error state in the View layer (like _shouldShowError).
                    return true
                case .error(_):
                    // TODO: handle error - update something like _shouldShowError RX variable which affect the UI state for showing error in the View layer
                    return false
                default:
                    return false
                }
            }
            .filter { $0 }
            .subscribe(onNext: { _ in
                // successfully muted
            })
            .disposed(by: disposeBag)

        // Handling muting comments "locally" of a muted user
        muteUserObservable
            .withLatestFrom(commentCellsVmsObservable) { userId, commentCellsVms -> (String, [OWCommentCellViewModeling]) in
                return (userId, commentCellsVms)
            }
            .map { [weak self] userId, commentCellsVms -> (SPUser, [OWCommentCellViewModeling])? in
                guard let self = self,
                      let user = self.servicesProvider.usersService().get(userId: userId)
                else { return nil }

                user.isMuted = true
                return (user, commentCellsVms)

            }
            .unwrap()
            .do(onNext: { [weak self] user, _ in
                guard let self = self else { return }
                self.servicesProvider
                    .usersService()
                    .set(users: [user])
            })
            .map { user, commentCellsVms -> (SPUser, [OWCommentViewModeling]) in
                let userCommentCells = commentCellsVms.filter { $0.outputs.commentVM.outputs.comment.userId == user.id }
                return (user, userCommentCells.map { $0.outputs.commentVM })
            }
            .observe(on: MainScheduler.instance)
            .do(onNext: { user, mutedUserCommentCellsVms in
                mutedUserCommentCellsVms.forEach {
                    $0.inputs.update(user: user)
                }
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self._performTableViewAnimation.onNext()
            })
            .disposed(by: disposeBag)

        servicesProvider
            .activeArticleService()
            .articleExtraData
            .subscribe(onNext: { [weak self] article in
                self?.articleUrl = article.url.absoluteString
            })
            .disposed(by: disposeBag)

        // This calls layoutIfNeeded to initial error loading comments cell, fixes height not always right
        willDisplayCell
            .withLatestFrom(shouldShowErrorLoadingComments) { ($0, $1) }
            .filter {  $0.0.cell.isKind(of: OWErrorStateCell.self) && $0.1 }
            .map { $0.0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { willDisplayCellEvent in
                willDisplayCellEvent.cell.layoutIfNeeded()
            })
            .disposed(by: disposeBag)

        scrolledToCellIndex
            .subscribe(onNext: { [weak self] _ in
                self?.dataSourceTransition = .animated
            })
            .disposed(by: disposeBag)

        // Handle perform action
        highlightCellIndex
            .delay(.milliseconds(Metrics.performActionDelay), scheduler: commentThreadViewVMScheduler)
            .withLatestFrom(selectedCommentCellVm)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] selectedCommentCellVm in
                guard let self = self else { return }
                let commentThreadSettings = self.commentThreadData.settings.commentThreadSettings
                let performActionType = commentThreadSettings.performActionType
                switch performActionType {
                case .changeRank(let from, let to):
                    let selectedCommentVm = selectedCommentCellVm.outputs.commentVM
                    if let fromRank = SPRank(rawValue: from),
                       let toRank = SPRank(rawValue: to) {
                        let rankChange = SPRankChange(from: fromRank, to: toRank)
                        self.performRankChange(for: selectedCommentVm, rankChange: rankChange)
                    }
                case .report:
                    self.servicesProvider
                        .reportedCommentsService()
                        .updateCommentReportedSuccessfully(commentId: self.commentThreadData.commentId,
                                                           postId: self.postId)

                default:
                    break
                }
            })
            .disposed(by: disposeBag)

    }

    func timeMeasuringMilliseconds(forKey key: OWTimeMeasuringService.OWKeys) -> Int {
        let measureService = servicesProvider.timeMeasuringService()
        let measureResult = measureService.endMeasure(forKey: key)
        if case OWTimeMeasuringResult.time(let milliseconds) = measureResult,
           milliseconds < Metrics.delayBeforeTryAgainAfterError {
            return milliseconds
        }
        // If end was called before start for some reason, returning 0 milliseconds here
        return 0
    }

    func event(for eventType: OWAnalyticEventType) -> OWAnalyticEvent {
        return servicesProvider
            .analyticsEventCreatorService()
            .analyticsEvent(
                for: eventType,
                articleUrl: articleUrl,
                layoutStyle: OWLayoutStyle(from: commentThreadData.presentationalStyle),
                component: .commentCreation)
    }

    func sendEvent(for eventType: OWAnalyticEventType) {
        let event = event(for: eventType)
        servicesProvider
            .analyticsService()
            .sendAnalyticEvents(events: [event])
    }
}
