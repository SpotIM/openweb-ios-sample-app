//
//  OWConversationViewVM.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

// swiftlint:disable file_length

import Foundation
import RxSwift
import RxCocoa

// Our sections is just a string as we will flat all the comments, replies, ads and everything into cells
typealias ConversationDataSourceModel = OWAnimatableSectionModel<String, OWConversationCellOption>

protocol OWConversationViewViewModelingInputs {
    var viewInitialized: PublishSubject<Void> { get }
    var willDisplayCell: PublishSubject<WillDisplayCellEvent> { get }
    var pullToRefresh: PublishSubject<Void> { get }
    var commentCreationTap: PublishSubject<OWCommentCreationTypeInternal> { get }
    var scrolledToCellIndex: PublishSubject<Int> { get }
    var changeConversationOffset: PublishSubject<CGPoint> { get }
}

protocol OWConversationViewViewModelingOutputs {
    var shouldShowTiTleHeader: Bool { get }
    var shouldShowArticleDescription: Bool { get }
    var shouldShowError: Observable<Void> { get }
    var shouldShowConversationEmptyState: Observable<Bool> { get }

    var conversationTitleHeaderViewModel: OWConversationTitleHeaderViewModeling { get }
    var articleDescriptionViewModel: OWArticleDescriptionViewModeling { get }
    var conversationSummaryViewModel: OWConversationSummaryViewModeling { get }
    var conversationEmptyStateViewModel: OWConversationEmptyStateViewModeling { get }
    var commentingCTAViewModel: OWCommentingCTAViewModel { get }

    var communityGuidelinesCellViewModel: OWCommunityGuidelinesCellViewModeling { get }
    var communityQuestionCellViewModel: OWCommunityQuestionCellViewModeling { get }
    // TODO: Decide if we need an OWConversationEmptyStateCell after final design in all orientations
//    var conversationEmptyStateCellViewModel: OWConversationEmptyStateCellViewModeling { get }
    var conversationDataSourceSections: Observable<[ConversationDataSourceModel]> { get }
    var performTableViewAnimation: Observable<Void> { get }
    var scrollToCellIndex: Observable<Int> { get }

    var urlClickedOutput: Observable<URL> { get }
    var openCommentCreation: Observable<OWCommentCreationTypeInternal> { get }
    var openProfile: Observable<URL> { get }
    var openPublisherProfile: Observable<String> { get }
    var openReportReason: Observable<OWCommentViewModeling> { get }
    var conversationOffset: Observable<CGPoint> { get }
    var dataSourceTransition: OWViewTransition { get }
    var conversationDataJustReceived: Observable<Void> { get }
}

protocol OWConversationViewViewModeling {
    var inputs: OWConversationViewViewModelingInputs { get }
    var outputs: OWConversationViewViewModelingOutputs { get }
}

class OWConversationViewViewModel: OWConversationViewViewModeling,
                                    OWConversationViewViewModelingInputs,
                                    OWConversationViewViewModelingOutputs {
    var inputs: OWConversationViewViewModelingInputs { return self }
    var outputs: OWConversationViewViewModelingOutputs { return self }

    fileprivate struct Metrics {
        static let numberOfSkeletonComments: Int = 5
        static let delayForPerformGuidelinesViewAnimation: Int = 500 // ms
        static let delayForPerformTableViewAnimation: Int = 10 // ms
        static let delayAfterRecievingUpdatedComments: Int = 500 // ms
        static let delayAfterScrolledToIndex: Int = 500 // ms
        static let delayBeforeReEnablingTableViewAnimation: Int = 500 // ms
        static let tableViewPaginationCellsOffset: Int = 5
        static let collapsableTextLineLimit: Int = 4
    }

    fileprivate let loadMoreCommentsScheduler: SchedulerType = SerialDispatchQueueScheduler(qos: .userInitiated, internalSerialQueueName: "loadMoreCommentsQueue")

    fileprivate var postId: OWPostId {
        return OWManager.manager.postId ?? ""
    }

    lazy var shouldShowArticleDescription: Bool = {
        return conversationData.article.additionalSettings.headerStyle != .none
    }()

    var _shouldShowError = PublishSubject<Void>()
    var shouldShowError: Observable<Void> {
        return _shouldShowError
            .asObservable()
    }

    var commentCreationTap = PublishSubject<OWCommentCreationTypeInternal>()
    var openCommentCreation: Observable<OWCommentCreationTypeInternal> {
        return commentCreationTap
            .asObservable()
    }

    var shouldShowTiTleHeader: Bool {
        return viewableMode == .independent
    }

    fileprivate var paginationOffset = 0

    fileprivate var _commentsPresentationData = OWObservableArray<OWCommentPresentationData>()

    fileprivate let _loadMoreReplies = PublishSubject<OWCommentPresentationData>()
    fileprivate let _loadMoreComments = PublishSubject<Int>()
    fileprivate let isLoadingMoreComments = BehaviorSubject<Bool>(value: false)

    fileprivate let _insertNewLocalComments = PublishSubject<[OWComment]>()
    fileprivate let _updateLocalComment = PublishSubject<(OWComment, OWCommentId)>()
    fileprivate let _replyToLocalComment = PublishSubject<(OWComment, OWCommentId)>()
    fileprivate let _scrollToCellIndex = PublishSubject<Int>()
    var scrolledToCellIndex = PublishSubject<Int>()

    var scrollToCellIndex: Observable<Int> {
        _scrollToCellIndex
            .asObservable()
    }

    fileprivate lazy var _isReadOnly = BehaviorSubject<Bool>(value: conversationData.article.additionalSettings.readOnlyMode == .enable)
    fileprivate lazy var isReadOnly: Observable<Bool> = {
        return _isReadOnly
            .share(replay: 1)
    }()

    fileprivate var _openProfile = PublishSubject<URL>()
    var openProfile: Observable<URL> {
        return _openProfile
            .asObservable()
    }

    fileprivate var _openPublisherProfile = PublishSubject<String>()
    var openPublisherProfile: Observable<String> {
        return _openPublisherProfile
            .asObservable()
    }

    fileprivate var _conversationDataJustReceived = PublishSubject<Void>()
    var conversationDataJustReceived: Observable<Void> {
        return _conversationDataJustReceived
            .asObservable()
    }

    fileprivate var _urlClick = PublishSubject<URL>()
    var urlClickedOutput: Observable<URL> {
        return _urlClick
            .asObservable()
    }

    fileprivate var deleteComment = PublishSubject<OWCommentViewModeling>()
    fileprivate var muteCommentUser = PublishSubject<OWCommentViewModeling>()

    lazy var conversationTitleHeaderViewModel: OWConversationTitleHeaderViewModeling = {
        return OWConversationTitleHeaderViewModel()
    }()

    lazy var articleDescriptionViewModel: OWArticleDescriptionViewModeling = {
        return OWArticleDescriptionViewModel(article: conversationData.article)
    }()

    lazy var conversationSummaryViewModel: OWConversationSummaryViewModeling = {
        return OWConversationSummaryViewModel()
    }()

    lazy var communityQuestionCellViewModel: OWCommunityQuestionCellViewModeling = {
        return OWCommunityQuestionCellViewModel(style: conversationStyle.communityQuestionStyle)
    }()

    lazy var communitySpacerCellViewModel: OWSpacerCellViewModeling = {
        return OWSpacerCellViewModel(style: .community)
    }()

    lazy var communityGuidelinesCellViewModel: OWCommunityGuidelinesCellViewModeling = {
        return OWCommunityGuidelinesCellViewModel(style: conversationStyle.communityGuidelinesStyle)
    }()

    // TODO: Decide if we need an OWConversationEmptyStateCell after final design in all orientations
//    lazy var conversationEmptyStateCellViewModel: OWConversationEmptyStateCellViewModeling = {
//        return OWConversationEmptyStateCellViewModel()
//    }()

    lazy var conversationEmptyStateViewModel: OWConversationEmptyStateViewModeling = {
        return OWConversationEmptyStateViewModel()
    }()

    fileprivate lazy var shouldShowCommunityQuestion: Observable<Bool> = {
        return communityQuestionCellViewModel.outputs
            .communityQuestionViewModel.outputs
            .shouldShowView
    }()

    fileprivate lazy var shouldShowCommunityGuidelines: Observable<Bool> = {
        return communityGuidelinesCellViewModel.outputs
            .communityGuidelinesViewModel.outputs
            .shouldShowView
    }()

    fileprivate lazy var commentCellsOptions: Observable<[OWConversationCellOption]> = {
        return _commentsPresentationData
            .rx_elements()
            .flatMapLatest({ [weak self] commentsPresentationData -> Observable<[OWConversationCellOption]> in
                guard let self = self else { return Observable.never() }

                return Observable.just(self.getCommentCells(for: commentsPresentationData))
            })
            .asObservable()
    }()

    fileprivate lazy var communityCellsOptions: Observable<[OWConversationCellOption]> = {
        return Observable.combineLatest(shouldShowCommunityQuestion, shouldShowCommunityGuidelines)
            .flatMapLatest({ [weak self] showCommunityQuestion, showCommunityGuidlines -> Observable<[OWConversationCellOption]> in
                guard let self = self else { return Observable.never() }
                return Observable.just(self.getCommunityCells(shouldShowCommunityQuestion: showCommunityQuestion, shouldShowCommunityGuidelines: showCommunityGuidlines))
            })
            .asObservable()
    }()

    fileprivate lazy var cellsViewModels: Observable<[OWConversationCellOption]> = {
        return Observable.combineLatest(communityCellsOptions, commentCellsOptions, isEmptyObservable)
            .startWith(([], [], false))
            .flatMapLatest({ [weak self] communityCellsOptions, commentCellsOptions, isEmptyConversation -> Observable<[OWConversationCellOption]> in
                guard let self = self else { return Observable.never() }
                if commentCellsOptions.isEmpty && !isEmptyConversation {
                    return Observable.just(self.getSkeletonCells())
                }
                return Observable.just(communityCellsOptions + commentCellsOptions)
            })
            .scan([], accumulator: { previousConversationCellsOptions, newConversationCellsOptions in
                var commentsVmsMapper = [OWCommentId: OWCommentCellViewModeling]()

                previousConversationCellsOptions.forEach { conversationCellOption in
                    switch conversationCellOption {
                    case .comment(let commentCellViewModel):
                        guard let commentId = commentCellViewModel.outputs.commentVM.outputs.comment.id else { return }
                        commentsVmsMapper[commentId] = commentCellViewModel
                    default:
                        break
                    }
                }

                let adjustedNewCommentCellOptions: [OWConversationCellOption] = newConversationCellsOptions.map { conversationCellOptions in
                    switch conversationCellOptions {
                    case .comment(let viewModel):
                        guard let commentId = viewModel.outputs.commentVM.outputs.comment.id else {
                            return conversationCellOptions
                        }
                        if let commentVm = commentsVmsMapper[commentId] {
                            return OWConversationCellOption.comment(viewModel: commentVm)
                        } else {
                            return conversationCellOptions
                        }
                    default:
                        return conversationCellOptions
                    }
                }

                return adjustedNewCommentCellOptions
            })
            .share(replay: 1)
            .asObservable()
    }()

    var conversationDataSourceSections: Observable<[ConversationDataSourceModel]> {
        return cellsViewModels
            .map { [weak self] items in
                guard let self = self else { return [] }
                let section = ConversationDataSourceModel(model: self.postId, items: items)
                return [section]
            }
    }

    fileprivate var _performTableViewAnimation = PublishSubject<Void>()
    var performTableViewAnimation: Observable<Void> {
        return _performTableViewAnimation
            .asObservable()
    }

    var shouldShowConversationEmptyState: Observable<Bool> {
        return isEmptyObservable
            .asObservable()
    }

    lazy var commentingCTAViewModel: OWCommentingCTAViewModel = {
        return OWCommentingCTAViewModel(imageProvider: imageProvider)
    }()

    fileprivate lazy var spacerCellViewModel: OWSpacerCellViewModeling = {
        return OWSpacerCellViewModel(style: .none)
    }()

    fileprivate lazy var communityQuestionCellOption: OWConversationCellOption = {
        return OWConversationCellOption.communityQuestion(viewModel: communityQuestionCellViewModel)
    }()

    fileprivate lazy var communityGuidelinesCellOption: OWConversationCellOption = {
        return OWConversationCellOption.communityGuidelines(viewModel: communityGuidelinesCellViewModel)
    }()

    // TODO: Decide if we need an OWConversationEmptyStateCell after final design in all orientations
//    fileprivate lazy var conversationEmptyStateCellOption: OWConversationCellOption = {
//        return OWConversationCellOption.conversationEmptyState(viewModel: conversationEmptyStateCellViewModel)
//    }()

    fileprivate lazy var communitySpacerCellOption: OWConversationCellOption = {
        return OWConversationCellOption.spacer(viewModel: communitySpacerCellViewModel)
    }()

    fileprivate lazy var conversationStyle: OWConversationStyle = {
        return self.conversationData.settings.fullConversationSettings.style
    }()

    var viewInitialized = PublishSubject<Void>()
    var willDisplayCell = PublishSubject<WillDisplayCellEvent>()
    var pullToRefresh = PublishSubject<Void>()

    fileprivate var _isEmpty = BehaviorSubject<Bool>(value: false)
    fileprivate lazy var isEmptyObservable: Observable<Bool> = {
        return _isEmpty
            .share(replay: 1)
            .asObservable()
    }()

    fileprivate var openReportReasonChange = PublishSubject<OWCommentViewModeling>()
    var openReportReason: Observable<OWCommentViewModeling> {
        return openReportReasonChange
            .asObservable()
    }

    var changeConversationOffset = PublishSubject<CGPoint>()
    var conversationOffset: Observable<CGPoint> {
        return changeConversationOffset
            .asObservable()
    }

    var dataSourceTransition: OWViewTransition = .reload

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let commentPresentationDataHelper: OWCommentsPresentationDataHelperProtocol
    fileprivate let imageProvider: OWImageProviding
    fileprivate let conversationData: OWConversationRequiredData
    fileprivate let viewableMode: OWViewableMode
    fileprivate let disposeBag = DisposeBag()

    init (servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
          commentPresentationDataHelper: OWCommentsPresentationDataHelperProtocol = OWCommentsPresentationDataHelper(),
          imageProvider: OWImageProviding = OWCloudinaryImageProvider(),
          conversationData: OWConversationRequiredData,
          viewableMode: OWViewableMode) {
        self.servicesProvider = servicesProvider
        self.commentPresentationDataHelper = commentPresentationDataHelper
        self.imageProvider = imageProvider
        self.conversationData = conversationData
        self.viewableMode = viewableMode
        setupObservers()

        sendEvent(for: .fullConversationViewed)
    }
}

fileprivate extension OWConversationViewViewModel {
    func getCommentCells(for commentsPresentationData: [OWCommentPresentationData]) -> [OWConversationCellOption] {
        var cellOptions = [OWConversationCellOption]()

        for (idx, commentPresentationData) in commentsPresentationData.enumerated() {
            guard let commentCellVM = self.getCommentCellVm(for: commentPresentationData.id) else { continue }

            if (commentCellVM.outputs.commentVM.outputs.comment.depth == 0 && idx > 0) {
                cellOptions.append(OWConversationCellOption.spacer(viewModel: OWSpacerCellViewModel(
                    id: "\(commentPresentationData.id)_spacer",
                    style: .comment
                )))
            }

            cellOptions.append(OWConversationCellOption.comment(viewModel: commentCellVM))

            let depth = commentCellVM.outputs.commentVM.outputs.comment.depth ?? 0

            let repliesToShowCount = commentPresentationData.repliesPresentation.count

            switch (repliesToShowCount, commentPresentationData.totalRepliesCount) {
            case (_, 0):
                break
            case (0, _):
                cellOptions.append(OWConversationCellOption.commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel(
                    id: "\(commentPresentationData.id)_expand_only",
                    data: commentPresentationData,
                    mode: .expand,
                    depth: depth
                )))
            default:
                cellOptions.append(OWConversationCellOption.commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel(
                    id: "\(commentPresentationData.id)_collapse",
                    data: commentPresentationData,
                    mode: .collapse,
                    depth: depth
                )))

                cellOptions.append(contentsOf: getCommentCells(for: commentPresentationData.repliesPresentation))

                if (repliesToShowCount < commentPresentationData.totalRepliesCount) {
                    cellOptions.append(OWConversationCellOption.commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel(
                        id: "\(commentPresentationData.id)_expand",
                        data: commentPresentationData,
                        mode: .expand,
                        depth: depth
                    )))
                }
            }
        }
        return cellOptions
    }

    func getCommunityCells(shouldShowCommunityQuestion: Bool, shouldShowCommunityGuidelines: Bool) -> [OWConversationCellOption] {
        var cells = [OWConversationCellOption]()

        switch (shouldShowCommunityQuestion, shouldShowCommunityGuidelines) {
        case (true, true):
            cells.append(contentsOf: [self.communityQuestionCellOption,
                                      self.communitySpacerCellOption,
                                      self.communityGuidelinesCellOption])
        case (true, false):
            cells.append(self.communityQuestionCellOption)
        case (false, true):
            cells.append(self.communityGuidelinesCellOption)
        default:
            break
        }

        return cells
    }

    func getSkeletonCells() -> [OWConversationCellOption] {
        let skeletonCellVMs = (0 ..< Metrics.numberOfSkeletonComments).map { _ in
            OWCommentSkeletonShimmeringCellViewModel()
        }
        let skeletonCells = skeletonCellVMs.map { OWConversationCellOption.commentSkeletonShimmering(viewModel: $0) }

        return skeletonCells
    }

    func getCommentsPresentationData(from response: OWConversationReadRM) -> [OWCommentPresentationData] {
        guard let responseComments = response.conversation?.comments else { return [] }

        let comments: [OWComment] = Array(responseComments)

        var commentsPresentationData = [OWCommentPresentationData]()
        var repliesPresentationData = [OWCommentPresentationData]()

        self.paginationOffset = response.conversation?.offset ?? 0

        for comment in comments {
            guard let commentId = comment.id else { continue }

            if let replies = comment.replies {

                repliesPresentationData = []

                for reply in replies {
                    guard let replyId = reply.id else { continue }

                    let replyPresentationData = OWCommentPresentationData(
                        id: replyId,
                        repliesIds: reply.replies?.map { $0.id }.unwrap() ?? [],
                        totalRepliesCount: reply.repliesCount ?? 0,
                        repliesOffset: reply.offset ?? 0,
                        repliesPresentation: []
                    )

                    repliesPresentationData.append(replyPresentationData)
                }
            }

            let commentPresentationData = OWCommentPresentationData(
                id: commentId,
                repliesIds: comment.replies?.map { $0.id }.unwrap() ?? [],
                totalRepliesCount: comment.repliesCount ?? 0,
                repliesOffset: comment.offset ?? 0,
                repliesPresentation: repliesPresentationData
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
            collapsableTextLineLimit: Metrics.collapsableTextLineLimit,
            section: self.conversationData.article.additionalSettings.section
        ))
    }

    func cacheConversationRead(response: OWConversationReadRM) {
        if let responseComments = response.conversation?.comments {
            self.servicesProvider.commentsService().set(comments: responseComments, postId: self.postId)
        }
        if let responseUsers = response.conversation?.users {
            self.servicesProvider.usersService().set(users: responseUsers)
        }
    }
}

fileprivate extension OWConversationViewViewModel {
    // swiftlint:disable function_body_length
    func setupObservers() {
        // Subscribing to start realtime service
        viewInitialized
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                self.servicesProvider.realtimeService().startFetchingData(postId: self.postId)
            })
            .disposed(by: disposeBag)

        // Observable for the sort option
        let sortOptionObservable = self.servicesProvider
            .sortDictateService()
            .sortOption(perPostId: self.postId)

        // Observable for the conversation network API
        let conversationReadObservable = sortOptionObservable
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dataSourceTransition = .reload // Block animations in the table view
            })
            .flatMapLatest { [weak self] sortOption -> Observable<Event<OWConversationReadRM>> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                .netwokAPI()
                .conversation
                .conversationRead(mode: sortOption, page: OWPaginationPage.first, parentId: "", offset: 0)
                .response
                .materialize() // Required to keep the final subscriber even if errors arrived from the network
            }

        let conversationFetchedObservable = Observable.merge(viewInitialized, pullToRefresh)
            .flatMapLatest { _ -> Observable<Event<OWConversationReadRM>> in
                return conversationReadObservable
            }
            .map { [weak self] event -> OWConversationReadRM? in
                guard let self = self else { return nil }
                switch event {
                case .next(let conversationRead):
                    // TODO: Clear any RX variables which affect error state in the View layer (like _shouldShowError).

                    // TODO: where should this be? we want this befor any analytics!
                    if let article = self.conversationData.article as? OWArticle {
                        article.onConversationRead(extractData: conversationRead.extractData)
                        self.articleDescriptionViewModel.inputs.newArticle.onNext(article)
                    }

                    return conversationRead
                case .error(_):
                    // TODO: handle error - update the UI state for showing error in the View layer
                    self._shouldShowError.onNext()
                    return nil
                default:
                    return nil
                }
            }
            .unwrap()
            .share()

        // First conversation load - send event
        conversationFetchedObservable
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.sendEvent(for: .fullConversationLoaded)
            })
            .disposed(by: disposeBag)

        // Each time the whole conversation loaded with new data except the first time
        conversationFetchedObservable
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                self?._conversationDataJustReceived.onNext(())
            })
            .disposed(by: disposeBag)

        // first load comments / refresh comments / sorted changed
        conversationFetchedObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }

                self.cacheConversationRead(response: response)

                let commentsPresentationData = self.getCommentsPresentationData(from: response)

                self._commentsPresentationData.removeAll()
                self._commentsPresentationData.append(contentsOf: commentsPresentationData)
            })
            .disposed(by: disposeBag)

        // Set isEmpty
        conversationFetchedObservable
            .subscribe(onNext: { [weak self] conversation in
                guard let self = self else { return }
                if let messageCount = conversation.conversation?.messagesCount, messageCount > 0 {
                    self._isEmpty.onNext(false)
                } else {
                    self._isEmpty.onNext(true)
                }
            })
            .disposed(by: disposeBag)

        // Set read only mode
        conversationFetchedObservable
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                var isReadOnly: Bool = response.conversation?.readOnly ?? false
                switch self.conversationData.article.additionalSettings.readOnlyMode {
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

        // After conversation fetched - i.e By the user changing sort option / pull to refresh / or initial load
        // Re-enabling animations in the conversation table view
        conversationFetchedObservable
            .delay(.milliseconds(Metrics.delayBeforeReEnablingTableViewAnimation), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dataSourceTransition = .animated
            })
            .disposed(by: disposeBag)

        isReadOnly
            .bind(to: commentingCTAViewModel.inputs.isReadOnly)
            .disposed(by: disposeBag)

        isReadOnly
            .bind(to: conversationEmptyStateViewModel.inputs.isReadOnly)
            .disposed(by: disposeBag)

        isEmptyObservable
            .bind(to: conversationEmptyStateViewModel.inputs.isEmpty)
            .disposed(by: disposeBag)

        commentingCTAViewModel
            .outputs
            .commentCreationTapped
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.sendEvent(for: .createCommentCTAClicked)
            })
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.commentCreationTap.onNext(.comment)
            })
            .disposed(by: disposeBag)

        // Binding to community question component
        conversationFetchedObservable
            .bind(to: communityQuestionCellViewModel.outputs.communityQuestionViewModel.inputs.conversationFetched)
            .disposed(by: disposeBag)

        let loadMoreRepliesReadObservable = _loadMoreReplies
            .withLatestFrom(sortOptionObservable) { (commentPresentationData, sortOption) -> (OWCommentPresentationData, OWSortOption)  in
                return (commentPresentationData, sortOption)
            }
            .flatMap { [weak self] (commentPresentationData, sortOption) -> Observable<(OWCommentPresentationData, Event<OWConversationReadRM>?)> in
                guard let self = self else { return .empty() }

                let countAfterUpdate = min(commentPresentationData.repliesPresentation.count + 5, commentPresentationData.totalRepliesCount)

                if countAfterUpdate <= commentPresentationData.repliesIds.count {
                    // no need to fetch more comments
                    return Observable.just((commentPresentationData, nil))
                }

                let currentRepliesCount = commentPresentationData.repliesIds.count
                let fetchCount = countAfterUpdate - currentRepliesCount

                return self.servicesProvider
                    .netwokAPI()
                    .conversation
                    .conversationRead(mode: sortOption, page: .next, count: fetchCount, parentId: commentPresentationData.id, offset: commentPresentationData.repliesOffset)
                    .response
                    .materialize()
                    .map { (commentPresentationData, $0) }
            }

        let loadMoreRepliesReadUpdated = loadMoreRepliesReadObservable
            .map { [weak self] (commentPresentationData, event) -> (OWCommentPresentationData, OWConversationReadRM?)? in
                guard let self = self else { return nil }
                guard event != nil else {
                    // We didn't have to fetch new data - the event is nil
                    return (commentPresentationData, nil)
                }

                switch event {
                case .next(let conversationRead):
                    // TODO: Clear any RX variables which affect error state in the View layer (like _shouldShowError).
                    return (commentPresentationData, conversationRead)
                case .error(_):
                    // TODO: handle error - update the UI state for showing error in the View layer
                    self._shouldShowError.onNext()
                    return nil
                default:
                    return nil
                }
            }
            .unwrap()

        loadMoreRepliesReadUpdated
            .subscribe(onNext: { [weak self] (commentPresentationData, response) in
            guard let self = self else { return }

            let existingRepliesPresentationData = self.getExistingRepliesPresentationData(for: commentPresentationData)

            // add presentation data from response
            var presentationDataFromResponse: [OWCommentPresentationData] = []
            if let response = response {
                self.cacheConversationRead(response: response)

                presentationDataFromResponse = self.getCommentsPresentationData(from: response)

                // filter existing comments
                presentationDataFromResponse = presentationDataFromResponse.filter { !commentPresentationData.repliesIds.contains($0.id) }

                // filter existing reply ids
                let newRepliesIds = (response.conversation?.comments?.map { $0.id })?.unwrap().filter { !commentPresentationData.repliesIds.contains($0) }

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

        })
        .disposed(by: disposeBag)

        // fetch more comments
        let loadMoreCommentsReadObservable = _loadMoreComments
            .observe(on: loadMoreCommentsScheduler)
            .withLatestFrom(sortOptionObservable) { (offset, sortOption) -> (OWSortOption, Int) in
                return (sortOption, offset)
            }
            .flatMap { [weak self] (sortOption, offset) -> Observable<Event<OWConversationReadRM>> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                .netwokAPI()
                .conversation
                .conversationRead(mode: sortOption, page: OWPaginationPage.next, parentId: "", offset: offset)
                .response
                .materialize() // Required to keep the final subscriber even if errors arrived from the network
            }

        let loadMoreCommentsReadFetched = loadMoreCommentsReadObservable
            .map { [weak self] event -> OWConversationReadRM? in
                guard let self = self else { return nil }
                self.isLoadingMoreComments.onNext(false)
                switch event {
                case .next(let conversationRead):
                    // TODO: Clear any RX variables which affect error state in the View layer (like _shouldShowError).
                    return conversationRead
                case .error(_):
                    // TODO: handle error - update the UI state for showing error in the View layer
                    self._shouldShowError.onNext()
                    return nil
                default:
                    return nil
                }
            }
            .unwrap()

        // append new comments on load more
        loadMoreCommentsReadFetched
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }

                self.cacheConversationRead(response: response)

                var commentsPresentationData = self.getCommentsPresentationData(from: response)

                commentsPresentationData = commentsPresentationData.filter { !(self._commentsPresentationData.map { $0.id }).contains($0.id) }

                self._commentsPresentationData.append(contentsOf: commentsPresentationData)
            })
            .disposed(by: disposeBag)

        // Responding to guidelines height change (for updating cell)
        cellsViewModels
            .flatMapLatest { cellsVms -> Observable<Void> in
                let sizeChangeObservable: [Observable<Void>] = cellsVms.map { vm in
                    if case.communityGuidelines(let guidelinesCellViewModel) = vm {
                        let guidelinesVM = guidelinesCellViewModel.outputs.communityGuidelinesViewModel
                        return guidelinesVM.outputs.shouldShowView
                            .filter { $0 == true }
                            .voidify()
                    } else {
                        return nil
                    }
                }
                .unwrap()
                return Observable.merge(sizeChangeObservable)
            }
            .delay(.milliseconds(Metrics.delayForPerformGuidelinesViewAnimation), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                self?._performTableViewAnimation.onNext()
            })
            .disposed(by: disposeBag)

        // Responding to comment height change (for updating cell)
        cellsViewModels
            .flatMapLatest { cellsVms -> Observable<Void> in
                let sizeChangeObservable: [Observable<Void>] = cellsVms.map { vm in
                    if case.comment(let commentCellViewModel) = vm {
                        let commentVM = commentCellViewModel.outputs.commentVM
                        return commentVM.outputs.contentVM
                            .outputs.collapsableLabelViewModel.outputs.height
                            .voidify()
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
            .flatMap { commentThreadActionsCellsVms -> Observable<(OWCommentPresentationData, OWCommentThreadActionsCellMode)> in
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
                    commentPresentationData.setRepliesPresentation([])
                    commentPresentationData.update.onNext()
                case .expand:
                    self.sendEvent(for: .loadMoreRepliesClicked(commentId: commentPresentationData.id))
                    self._loadMoreReplies.onNext(commentPresentationData)
                }

            })
            .disposed(by: disposeBag)

        // Observe tableview will display cell to load more comments
        willDisplayCell
            .map { willDisplayCellEvent -> Int in
                return willDisplayCellEvent.indexPath.row
            }
            .withLatestFrom(_commentsPresentationData.rx_elements()) { rowIndex, presentationData -> Int? in
                guard !presentationData.isEmpty else { return nil }
                return rowIndex
            }
            .unwrap()
            .withLatestFrom(isLoadingMoreComments) { rowIndex, isLoadingMoreComments in
                return (rowIndex, isLoadingMoreComments)
            }
            .filter { !$0.1 }
            .map { $0.0 }
            .withLatestFrom(cellsViewModels) { rowIndex, cellsVMs in
                return (rowIndex > (cellsVMs.count - Metrics.tableViewPaginationCellsOffset))
            }
            .filter { $0 }
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.sendEvent(for: .loadMoreComments(paginationOffset: self.paginationOffset))
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.isLoadingMoreComments.onNext(true)
                self._loadMoreComments.onNext(self.paginationOffset)
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
                guard let self = self else { return }
                self.sendEvent(for: .commentMenuClicked(commentId: commentVm.outputs.comment.id ?? ""))
            })
            .flatMapLatest { [weak self] (actions, sender, commentVm) -> Observable<(OWRxPresenterResponseType, OWCommentViewModeling)> in
                guard let self = self else { return .empty()}
                return self.servicesProvider.presenterService()
                    .showMenu(actions: actions, sender: sender, viewableMode: self.viewableMode)
                    .map { ($0, commentVm) }
            }
            .observe(on: MainScheduler.instance)
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

        // Observe on rank click
        commentCellsVmsObservable
            .flatMap { commentCellsVms -> Observable<(OWCommentId, SPRankChange)> in
                let rankClickObservable: [Observable<(OWCommentId, SPRankChange)>] = commentCellsVms.map { commentCellVm -> Observable<(OWCommentId, SPRankChange)> in
                    let commentRankVm = commentCellVm.outputs.commentVM.outputs.commentEngagementVM.outputs.votingVM

                    return commentRankVm.outputs.rankChanged
                        .map { (commentCellVm.outputs.commentVM.outputs.comment.id ?? "", $0) }
                }
                return Observable.merge(rankClickObservable)
            }
            .subscribe(onNext: { [weak self] commentId, rank in
                guard let self = self,
                      let eventType = rank.analyticsEventType(commentId: commentId)
                else { return }
                self.sendEvent(for: eventType)
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
                        title: OWLocalizationManager.shared.localizedString(key: "Whoops! Looks like we’re\nexperiencing some\nconnectivity issues."),
                        message: "",
                        actions: actions,
                        viewableMode: self.viewableMode
                    )
                    .subscribe(onNext: { result in
                        switch result {
                        case .completion:
                            // Do nothing
                            break
                        case .selected(_):
                            break
                        }
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)

        // Open sort option menu
        conversationSummaryViewModel.outputs.conversationSortVM.outputs.openSort
            .withLatestFrom(sortOptionObservable) { sender, currentSort -> (OWUISource, OWSortOption) in
                return (sender, currentSort)
            }
            .do(onNext: { [weak self] _, currentSort in
                self?.sendEvent(for: .sortByClicked(currentSort: currentSort))
            })
            .flatMapLatest { [weak self] sender, currentSort -> Observable<(OWRxPresenterResponseType, OWSortOption)> in
                guard let self = self else { return .empty() }

                let sortDictateService = self.servicesProvider.sortDictateService()
                let actions = [
                    OWRxPresenterAction(title: sortDictateService.sortTextTitle(perOption: .best), type: OWSortMenu.sortBest),
                    OWRxPresenterAction(title: sortDictateService.sortTextTitle(perOption: .newest), type: OWSortMenu.sortNewest),
                    OWRxPresenterAction(title: sortDictateService.sortTextTitle(perOption: .oldest), type: OWSortMenu.sortOldest)
                    ]

                return self.servicesProvider.presenterService()
                    .showMenu(actions: actions, sender: sender, viewableMode: self.viewableMode)
                    .map { ($0, currentSort) }

            }
            .subscribe(onNext: { [weak self] typy, currentSort in
                guard let self = self else { return }
                switch (typy) {
                case .completion:
                    self.sendEvent(for: .sortByClosed(currentSort: currentSort))
                    return
                case .selected(action: let action):
                    let newSort: OWSortOption
                    switch (action.type) {
                    case OWSortMenu.sortBest: newSort = .best
                    case OWSortMenu.sortNewest: newSort = .newest
                    case OWSortMenu.sortOldest: newSort = .oldest
                    default:
                        newSort = .best
                    }

                    // Make sure the sort acutually changed
                    guard currentSort != newSort else { return }

                    // Event
                    self.sendEvent(for: .sortByChanged(previousSort: currentSort, selectedSort: newSort))
                    // Changing the sort in the service
                    let sortDictateService = self.servicesProvider.sortDictateService()
                    sortDictateService.update(sortOption: newSort, perPostId: self.postId)
                    // Remove all comments to show skeletons while loading new comments according to the new sort
                    self._commentsPresentationData.removeAll()
                }
            })
            .disposed(by: disposeBag)

        // Responding to comment avatar click
        commentCellsVmsObservable
            .flatMapLatest { commentCellsVms -> Observable<(URL, OWUserProfileType, String)> in
                let avatarClickOutputObservable: [Observable<(URL, OWUserProfileType, String)>] = commentCellsVms.map { commentCellVm in
                    let avatarVM = commentCellVm.outputs.commentVM.outputs.commentHeaderVM.outputs.avatarVM
                    return avatarVM.outputs.openProfile
                        .map { url, type in
                            return (url, type, commentCellVm.outputs.commentVM.outputs.comment.userId ?? "")
                        }
                }
                return Observable.merge(avatarClickOutputObservable)
            }
            .subscribe(onNext: { [weak self] url, type, userId in
                guard let self = self else { return }
                self._openProfile.onNext(url)
                switch type {
                case .currentUser: self.sendEvent(for: .myProfileClicked(source: .comment))
                case .otherUser: self.sendEvent(for: .userProfileClicked(userId: userId))
                }
            })
            .disposed(by: disposeBag)

        commentingCTAViewModel
            .outputs
            .openProfile
            .subscribe(onNext: { [weak self] _ in
                self?.sendEvent(for: .myProfileClicked(source: .commentCTA))
            })
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

        self.servicesProvider.commentUpdaterService()
            .getUpdatedComments(for: postId)
            .flatMap { updateType -> Observable<OWCommentUpdateType> in
                // Making sure comment cells are visible
                return commentCellsVmsObservable
                    .filter { !$0.isEmpty }
                    .take(1)
                    .map { _ in updateType }
            }
            .delay(.milliseconds(Metrics.delayAfterRecievingUpdatedComments), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .subscribe(onNext: { [weak self] updateType in
                guard let self = self else { return }
                switch updateType {
                case .insert(let comments):
                    self._insertNewLocalComments.onNext(comments)
                case let .update(commentId, withComment):
                    self._updateLocalComment.onNext((withComment, commentId))
                case let .insertReply(comment, toCommentId):
                    self._replyToLocalComment.onNext((comment, toCommentId))
                }
            })
            .disposed(by: disposeBag)

        _insertNewLocalComments
            .do(onNext: { [weak self] _ in
                // scroll to top
                guard let self = self else { return }
                self._scrollToCellIndex.onNext(0)
            })
            .flatMapLatest { comments -> Observable<[OWComment]> in
                // waiting for scroll to top
                return self.scrolledToCellIndex
                    .filter { $0 == 0 }
                    .take(1)
                    .map { _ in comments }
            }
            .delay(.milliseconds(Metrics.delayAfterScrolledToIndex), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .subscribe(onNext: { [weak self] comments in
                guard let self = self else { return }
                let commentsIds = comments.map { $0.id }.unwrap()
                    .filter {
                        // making sure we are not adding an existing comment
                        self.commentPresentationDataHelper.findVisibleCommentPresentationData(with: $0, in: Array(self._commentsPresentationData)) == nil
                    }
                let updatedCommentsPresentationData = commentsIds.map { OWCommentPresentationData(id: $0) }
                if (!updatedCommentsPresentationData.isEmpty) {
                    self._commentsPresentationData.insert(contentsOf: updatedCommentsPresentationData, at: 0)
                }
            })
            .disposed(by: disposeBag)

        _updateLocalComment
            .withLatestFrom(commentCellsVmsObservable) { ($0.0, $0.1, $1) }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { comment, commentId, commentCellsVms in
                if let commentCellVm = commentCellsVms.first(where: { $0.outputs.commentVM.outputs.comment.id == commentId }) {
                    commentCellVm.outputs.commentVM.inputs.updateEditedCommentLocally(updatedComment: comment)
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

        // Responding to comments which are just reported
        let reportService = servicesProvider.reportedCommentsService()
        reportService.commentJustReported
            .withLatestFrom(commentCellsVmsObservable) {
                ($0, $1)
            }
            .flatMap { commentId, commentCellVMs -> Observable<OWCommentViewModeling?> in
                // 1. Find if such comment VM exist for this comment ID
                guard let commentCellVM = commentCellVMs.first(where: { $0.outputs.commentVM.outputs.comment.id == commentId }) else {
                    return .empty()
                }
                return Observable.just(commentCellVM.outputs.commentVM)
            }
            .unwrap()
            .observe(on: MainScheduler.instance)
            .do(onNext: { commentVM in
                // 2. Update report locally
                commentVM.inputs.reportCommentLocally()
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                // 3. Update table view
                self._performTableViewAnimation.onNext()
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
                        title: OWLocalizationManager.shared.localizedString(key: "Delete Comment"),
                        message: OWLocalizationManager.shared.localizedString(key: "Do you really want to delete this comment?"),
                        actions: actions,
                        viewableMode: self.viewableMode
                    ).map { ($0, commentVm) }
            }
            .map { result, commentVm -> Bool in
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
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] commentVm in
                guard let self = self else { return }
                commentVm.inputs.deleteCommentLocally()
                self._performTableViewAnimation.onNext()
            })

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

        let muteUserObservable = muteCommentUser
            .asObservable()
            .flatMap { [weak self] _ -> Observable<OWRxPresenterResponseType> in
                guard let self = self else { return .empty() }
                let actions = [
                    OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "Mute"), type: OWCommentUserMuteAlert.mute, style: .destructive),
                    OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "Cancel"), type: OWCommentUserMuteAlert.cancel, style: .cancel)
                ]
                return self.servicesProvider.presenterService()
                    .showAlert(
                        title: OWLocalizationManager.shared.localizedString(key: "Mute User"),
                        message: OWLocalizationManager.shared.localizedString(key: "MuteUserMessage"),
                        actions: actions,
                        viewableMode: self.viewableMode
                    )
            }
            .map { result -> Bool in
                switch result {
                case .completion:
                    return false
                case .selected(let action):
                    switch action.type {
                    case OWCommentUserMuteAlert.mute:
                        return true
                    default:
                        return false
                    }
                }
            }
            .filter { $0 }
            .withLatestFrom(muteCommentUser)
            .map { $0.outputs.comment.userId }
            .unwrap()
            .share()

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
            .do(onNext: { [weak self] userId, _ in
                guard let self = self,
                      let user = self.servicesProvider.usersService().get(userId: userId)
                else { return }

                user.isMuted = true
                self.servicesProvider
                    .usersService()
                    .set(users: [user])
            })
            .map { userId, commentCellsVms -> [OWCommentViewModeling] in
                let userCommentCells = commentCellsVms.filter { $0.outputs.commentVM.outputs.comment.userId == userId }
                return userCommentCells.map { $0.outputs.commentVM }
            }
            .do(onNext: { mutedUserCommentCellsVms in
                mutedUserCommentCellsVms.forEach { $0.inputs.muteCommentLocally() }
            })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self._performTableViewAnimation.onNext()
            })
            .disposed(by: disposeBag)
    }

    func event(for eventType: OWAnalyticEventType) -> OWAnalyticEvent {
        return servicesProvider
            .analyticsEventCreatorService()
            .analyticsEvent(
                for: eventType,
                articleUrl: conversationData.article.url.absoluteString, // TODO:
                layoutStyle: OWLayoutStyle(from: conversationData.presentationalStyle),
                component: .conversation)
    }

    func sendEvent(for eventType: OWAnalyticEventType) {
        let event = event(for: eventType)
        servicesProvider
            .analyticsService()
            .sendAnalyticEvents(events: [event])
    }
}
