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
    var scrolledToTop: PublishSubject<Void> { get }
    var changeConversationOffset: PublishSubject<CGPoint> { get }
    var tableViewHeight: PublishSubject<CGFloat> { get }
    var tableViewContentOffsetY: PublishSubject<CGFloat> { get }
    var tableViewContentSizeHeight: PublishSubject<CGFloat> { get }
}

protocol OWConversationViewViewModelingOutputs {
    var shouldShowTitleHeader: Bool { get }
    var shouldShowArticleDescription: Bool { get }
    var shouldShowErrorLoadingComments: Observable<Bool> { get }
    var shouldShowErrorLoadingMoreComments: Observable<Bool> { get }
    var shouldShowErrorCommentDelete: Observable<Bool> { get }
    var shouldShowErrorMuteUser: Observable<Bool> { get }
    var shouldShowConversationEmptyState: Observable<Bool> { get }

    var conversationTitleHeaderViewModel: OWConversationTitleHeaderViewModeling { get }
    var articleDescriptionViewModel: OWArticleDescriptionViewModeling { get }
    var loginPromptViewModel: OWLoginPromptViewModeling { get }
    var conversationSummaryViewModel: OWConversationSummaryViewModeling { get }
    var commentingCTAViewModel: OWCommentingCTAViewModel { get }
    var realtimeIndicationAnimationViewModel: OWRealtimeIndicationAnimationViewModeling { get }

    var communityGuidelinesCellViewModel: OWCommunityGuidelinesCellViewModeling { get }
    var communityQuestionCellViewModel: OWCommunityQuestionCellViewModeling { get }
    var conversationEmptyStateCellViewModel: OWConversationEmptyStateCellViewModeling { get }
    var conversationDataSourceSections: Observable<[ConversationDataSourceModel]> { get }
    var performTableViewAnimation: Observable<Void> { get }
    var updateTableViewInstantly: Observable<Void> { get }
    var scrollToTopAnimated: Observable<Bool> { get }
    var scrollToCellIndex: Observable<Int> { get }
    var reloadCellIndex: Observable<Int> { get }

    var urlClickedOutput: Observable<URL> { get }
    var openCommentCreation: Observable<OWCommentCreationTypeInternal> { get }
    var openProfile: Observable<OWOpenProfileType> { get }
    var openReportReason: Observable<OWCommentViewModeling> { get }
    var openClarityDetails: Observable<OWClarityDetailsType> { get }
    var conversationOffset: Observable<CGPoint> { get }
    var dataSourceTransition: OWViewTransition { get }
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
        static let defaultNumberOfReplies: Int = 5
        static let numberOfSkeletonComments: Int = 5
        static let spacingBetweenCommentsDivisor: CGFloat = 2
        static let delayBeforeTryAgainAfterError: Int = 2000 // ms
        static let delayBeforeScrollingToLastCell: Int = 100 // ms
        static let delayForPerformGuidelinesViewAnimation: Int = 500 // ms
        static let delayForPerformTableViewAnimation: Int = 10 // ms
        static let debouncePerformTableViewAnimation: Int = 50 // ms
        static let updateTableViewInstantlyDelay: Int = 50 // ms
        static let delayForPerformTableViewAnimationErrorState: Int = 500 // ms
        static let delayAfterRecievingUpdatedComments: Int = 200 // ms
        static let delayAfterScrolledToTopAnimated: Int = 500 // ms
        static let delayBeforeReEnablingTableViewAnimation: Int = 500 // ms
        static let delayForPerformTableViewAnimationAfterContentSizeChanged: Int = 100 // ms
        static let tableViewPaginationCellsOffset: Int = 5
        static let collapsableTextLineLimit: Int = 4
        static let scrollUpThresholdForCancelScrollToLastCell: CGFloat = 800
        static let delayUpdateTableAfterLoadedReplies: Int = 450 // ms
    }

    fileprivate var errorsLoadingReplies: [OWCommentId: OWRepliesErrorState] = [:]

    fileprivate let conversationViewVMScheduler: SchedulerType = SerialDispatchQueueScheduler(qos: .userInitiated, internalSerialQueueName: "conversationViewVMQueue")

    var tableViewHeight = PublishSubject<CGFloat>()
    fileprivate lazy var tableViewHeightChanged: Observable<CGFloat> = {
        tableViewHeight
            .filter { $0 > 0 }
            .distinctUntilChanged()
            .asObservable()
    }()

    var tableViewContentOffsetY = PublishSubject<CGFloat>()
    fileprivate lazy var tableViewContentOffsetYChanged: Observable<CGFloat> = {
        tableViewContentOffsetY
            .asObservable()
    }()

    var tableViewContentSizeHeight = PublishSubject<CGFloat>()
    fileprivate lazy var tableViewContentSizeHeightChanged: Observable<CGFloat> = {
        tableViewContentSizeHeight
            .distinctUntilChanged()
            .asObservable()
    }()

    fileprivate var postId: OWPostId {
        return OWManager.manager.postId ?? ""
    }

    lazy var shouldShowArticleDescription: Bool = {
        return conversationData.article.additionalSettings.headerStyle != .none
    }()

    fileprivate var _tryAgainAfterError = PublishSubject<OWErrorStateTypes>()
    var tryAgainAfterError: Observable<OWErrorStateTypes> {
        return _tryAgainAfterError
            .asObservable()
    }

    fileprivate var _shouldShowErrorLoadingComments = BehaviorSubject<Bool>(value: false)
    var shouldShowErrorLoadingComments: Observable<Bool> {
        return _shouldShowErrorLoadingComments
            .asObservable()
    }

    fileprivate var _shouldShowErrorLoadingMoreComments = BehaviorSubject<Bool>(value: false)
    var shouldShowErrorLoadingMoreComments: Observable<Bool> {
        return _shouldShowErrorLoadingMoreComments
            .asObservable()
    }

    fileprivate var _shouldShowErrorCommentDelete = BehaviorSubject<Bool>(value: false)
    var shouldShowErrorCommentDelete: Observable<Bool> {
        return _shouldShowErrorCommentDelete
            .asObservable()
    }

    fileprivate var _shouldShowErrorMuteUser = BehaviorSubject<Bool>(value: false)
    var shouldShowErrorMuteUser: Observable<Bool> {
        return _shouldShowErrorMuteUser
            .asObservable()
    }

    var commentCreationTap = PublishSubject<OWCommentCreationTypeInternal>()
    var openCommentCreation: Observable<OWCommentCreationTypeInternal> {
        return commentCreationTap
            .asObservable()
    }

    var shouldShowTitleHeader: Bool {
        return viewableMode == .independent
    }

    fileprivate var conversationPaginationOffset = 0
    fileprivate var conversationHasNext = false

    fileprivate var articleUrl: String = ""

    fileprivate let _serverCommentsLoadingState = BehaviorSubject<OWLoadingState>(value: .loading(triggredBy: .initialLoading))
    fileprivate var serverCommentsLoadingState: Observable<OWLoadingState> {
        _serverCommentsLoadingState
            .asObservable()
    }
    fileprivate var _commentsPresentationData = OWObservableArray<OWCommentPresentationData>()

    fileprivate let _loadMoreReplies = PublishSubject<OWCommentPresentationData>()
    fileprivate let _loadMoreComments = PublishSubject<Int>()
    fileprivate let _isLoadingMoreComments = BehaviorSubject<Bool>(value: false)
    fileprivate var isLoadingMoreComments: Observable<Bool> {
        _isLoadingMoreComments
            .asObservable()
    }

    fileprivate let _insertNewLocalComments = PublishSubject<[OWComment]>()
    fileprivate let _updateLocalComment = PublishSubject<(OWComment, OWCommentId)>()
    fileprivate let _replyToLocalComment = PublishSubject<(OWComment, OWCommentId)>()

    fileprivate let _scrollToTopAnimated = PublishSubject<Bool>()
    var scrollToTopAnimated: Observable<Bool> {
        _scrollToTopAnimated
            .asObservable()
    }
    var scrolledToTop = PublishSubject<Void>()

    fileprivate var _scrollToCellIndex = PublishSubject<Int>()
    var scrollToCellIndex: Observable<Int> {
        _scrollToCellIndex
            .asObservable()
    }

    fileprivate var _reloadCellIndex = PublishSubject<Int>()
    var reloadCellIndex: Observable<Int> {
        _reloadCellIndex
            .asObservable()
    }

    fileprivate lazy var _isReadOnly = BehaviorSubject<Bool>(value: conversationData.article.additionalSettings.readOnlyMode == .enable)
    fileprivate lazy var isReadOnly: Observable<Bool> = {
        return _isReadOnly
            .share(replay: 1)
    }()

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

    lazy var conversationTitleHeaderViewModel: OWConversationTitleHeaderViewModeling = {
        return OWConversationTitleHeaderViewModel()
    }()

    lazy var articleDescriptionViewModel: OWArticleDescriptionViewModeling = {
        return OWArticleDescriptionViewModel()
    }()

    lazy var loginPromptViewModel: OWLoginPromptViewModeling = {
        return OWLoginPromptViewModel()
    }()

    lazy var conversationSummaryViewModel: OWConversationSummaryViewModeling = {
        return OWConversationSummaryViewModel()
    }()

    lazy var communityQuestionCellViewModel: OWCommunityQuestionCellViewModeling = {
        return OWCommunityQuestionCellViewModel(style: conversationStyle.communityQuestionStyle,
                                                spacing: conversationStyle.spacing)
    }()

    lazy var communitySpacerCellViewModel: OWSpacerCellViewModeling = {
        return OWSpacerCellViewModel(style: .community)
    }()

    lazy var communityGuidelinesCellViewModel: OWCommunityGuidelinesCellViewModeling = {
        return OWCommunityGuidelinesCellViewModel(style: conversationStyle.communityGuidelinesStyle,
                                                  spacing: conversationStyle.spacing)
    }()

    lazy var conversationEmptyStateCellViewModel: OWConversationEmptyStateCellViewModeling = {
        return OWConversationEmptyStateCellViewModel()
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
            .startWith([])
            .asObservable()
    }()

    fileprivate lazy var errorCellViewModels: Observable<[OWConversationCellOption]> = {
        return shouldShowErrorLoadingComments
            .filter { $0 }
            .flatMapLatest { [weak self] _ -> Observable<[OWConversationCellOption]> in
                guard let self = self else { return .empty() }
                return Observable.just(self.getErrorStateCell(errorStateType: .loadConversationComments))
            }
            .startWith([])
    }()

    // swiftlint:disable line_length
    fileprivate lazy var cellsViewModels: Observable<[OWConversationCellOption]> = {
        return Observable.combineLatest(communityCellsOptions,
                                        commentCellsOptions,
                                        serverCommentsLoadingState,
                                        shouldShowErrorLoadingComments,
                                        errorCellViewModels,
                                        shouldShowConversationEmptyState,
                                        shouldShowErrorLoadingMoreComments)
        .observe(on: conversationViewVMScheduler)
        .flatMapLatest({ [weak self] communityCellsOptions, commentCellsOptions, loadingState, shouldShowError, errorCellViewModels, isEmptyState, shouldShowErrorLoadingMoreComments -> Observable<[OWConversationCellOption]> in
                guard let self = self else { return Observable.never() }

                if case .loading(let loadingReason) = loadingState, loadingReason != .pullToRefresh {
                    return Observable.just(self.getSkeletonCells())
                } else if shouldShowError {
                    self._dataSourceTransition.onNext(.reload)
                    return Observable.just(errorCellViewModels)
                } else if isEmptyState {
                    let emptyStateCellOption = [OWConversationCellOption.conversationEmptyState(viewModel: self.conversationEmptyStateCellViewModel)]
                    return Observable.just(communityCellsOptions + emptyStateCellOption)
                } else {
                    let errorLoadingMoreCell = shouldShowErrorLoadingMoreComments ? self.getErrorStateCell(errorStateType: .loadMoreConversationComments) : []
                    var loadingCell = self.conversationHasNext && !shouldShowErrorLoadingMoreComments ? self.getLoadingCell() : []
                    return Observable.just(communityCellsOptions + commentCellsOptions + loadingCell + errorLoadingMoreCell)
                }
            })
            .map { cellOptions in
                return OWConversationScanData(cellOptions: cellOptions)
            }
            .scan(OWConversationScanData.empty, accumulator: { [weak self] previousScanData, newScanData in
                guard let self = self else { return OWConversationScanData.empty }

                var commentsVmsMapper = [OWCommentId: OWCommentCellViewModeling]()
                var commentThreadActionVmsMapper = [String: OWCommentThreadActionsCellViewModeling]()

                var commentVMsUpdateComment: [(OWCommentViewModeling, OWCommentViewModeling)] = []
                var commentVMsUpdateUser: [(OWCommentViewModeling, OWCommentViewModeling)] = []

                var previousConversationCellsOptions = previousScanData.cellOptions
                var newConversationCellsOptions = newScanData.cellOptions

                previousConversationCellsOptions.forEach { conversationCellOption in
                    switch conversationCellOption {
                    case .comment(let commentCellViewModel):
                        guard let commentId = commentCellViewModel.outputs.commentVM.outputs.comment.id else { return }
                        commentsVmsMapper[commentId] = commentCellViewModel
                    case .commentThreadActions(let commentThreadActionCellViewModel):
                        commentThreadActionVmsMapper[commentThreadActionCellViewModel.outputs.id] = commentThreadActionCellViewModel
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
                        if let commentCellVm = commentsVmsMapper[commentId] {
                            let commentVm = commentCellVm.outputs.commentVM
                            let updatedCommentVm = viewModel.outputs.commentVM

                            if (updatedCommentVm.outputs.comment != commentVm.outputs.comment) {
                                commentVMsUpdateComment.append((commentVm, updatedCommentVm))
                            }
                            if (updatedCommentVm.outputs.user != commentVm.outputs.user) {
                                commentVMsUpdateUser.append((commentVm, updatedCommentVm))
                            }
                            return OWConversationCellOption.comment(viewModel: commentCellVm)
                        } else {
                            return conversationCellOptions
                        }
                    case .commentThreadActions(let viewModel):
                        if let commentThreadActionVm = commentThreadActionVmsMapper[viewModel.outputs.id] {
                            if (ObjectIdentifier(viewModel.outputs.commentPresentationData) != ObjectIdentifier(commentThreadActionVm.outputs.commentPresentationData)) {
                                commentThreadActionVm.inputs.update(commentPresentationData: viewModel.outputs.commentPresentationData)
                            }
                            return OWConversationCellOption.commentThreadActions(viewModel: commentThreadActionVm)
                        } else {
                            return conversationCellOptions
                        }
                    default:
                        return conversationCellOptions
                    }
                }

                return OWConversationScanData(commentVMsUpdateComment: commentVMsUpdateComment,
                                              commentVMsUpdateUser: commentVMsUpdateUser,
                                              cellOptions: adjustedNewCommentCellOptions)
            })
            .observe(on: MainScheduler.instance)
            .do(onNext: { conversationScanData in
                for updateCommentTuples in conversationScanData.commentVMsUpdateComment {
                    updateCommentTuples.0.inputs.update(comment: updateCommentTuples.1.outputs.comment)
                }
                for updateUserTuples in conversationScanData.commentVMsUpdateUser {
                    updateUserTuples.0.inputs.update(comment: updateUserTuples.1.outputs.comment)
                }
            })
            .observe(on: conversationViewVMScheduler)
            .map { return $0.cellOptions }
            .asObservable()
            .share(replay: 1)
    }()
    // swiftlint:enable line_length

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
        return Observable.combineLatest(_performTableViewAnimation, _dataSourceTransition) { _, transition in
            return transition
        }
        .filter { transition in
            return transition == .animated
        }
        .voidify()
        .asObservable()
    }

    fileprivate var _updateTableViewInstantly = PublishSubject<Void>()
    var updateTableViewInstantly: Observable<Void> {
        return _updateTableViewInstantly
            .delay(.milliseconds(Metrics.updateTableViewInstantlyDelay), scheduler: conversationViewVMScheduler)
            .asObservable()
    }

    var shouldShowConversationEmptyState: Observable<Bool> {
        return Observable.combineLatest(serverCommentsLoadingState.distinctUntilChanged(),
                                        shouldShowErrorLoadingComments.distinctUntilChanged(),
                                        commentCellsOptions)
        .startWith( (.loading(triggredBy: .initialLoading), false, []) )
        .flatMapLatest { loadingState, shouldShowError, comments -> Observable<Bool> in
            guard loadingState == .notLoading, !shouldShowError else { return .just(false) }
            return .just(comments.isEmpty)
        }
        .distinctUntilChanged()
        .asObservable()
    }

    lazy var commentingCTAViewModel: OWCommentingCTAViewModel = {
        return OWCommentingCTAViewModel(imageProvider: imageProvider)
    }()

    lazy var realtimeIndicationAnimationViewModel: OWRealtimeIndicationAnimationViewModeling = {
        return OWRealtimeIndicationAnimationViewModel()
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

    fileprivate lazy var conversationEmptyStateCellOption: OWConversationCellOption = {
        return OWConversationCellOption.conversationEmptyState(viewModel: conversationEmptyStateCellViewModel)
    }()

    fileprivate lazy var communitySpacerCellOption: OWConversationCellOption = {
        return OWConversationCellOption.spacer(viewModel: communitySpacerCellViewModel)
    }()

    fileprivate lazy var conversationStyle: OWConversationStyle = {
        return self.conversationData.settings.fullConversationSettings.style
    }()

    fileprivate lazy var spacingBetweenComments: CGFloat = {
        return self.conversationStyle.spacing.betweenComments / Metrics.spacingBetweenCommentsDivisor
    }()

    var viewInitialized = PublishSubject<Void>()
    fileprivate lazy var viewInitializedObservable: Observable<OWLoadingTriggeredReason> = {
        return viewInitialized
            .map { OWLoadingTriggeredReason.initialLoading }
    }()

    var willDisplayCell = PublishSubject<WillDisplayCellEvent>()

    var pullToRefresh = PublishSubject<Void>()
    fileprivate lazy var pullToRefreshObservable: Observable<OWLoadingTriggeredReason> = {
        return pullToRefresh
            .withLatestFrom(shouldShowErrorLoadingComments)
            .do(onNext: { [weak self] shouldShowErrorLoadingComments in
                // This is for pull to refresh while error state for initial comments is shown
                // We want to show skeletons after this pull to refresh
                if shouldShowErrorLoadingComments {
                    guard let self = self else { return }
                    self._dataSourceTransition.onNext(.reload)
                    self._serverCommentsLoadingState.onNext(.loading(triggredBy: .tryAgainAfterError))
                    self._shouldShowErrorLoadingComments.onNext(false)
                    self.servicesProvider.timeMeasuringService().startMeasure(forKey: .conversationLoadingInitialComments)
                }
            })
            .map { _ -> OWLoadingTriggeredReason in
                OWLoadingTriggeredReason.pullToRefresh
            }
            .asObservable()
    }()

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

    var changeConversationOffset = PublishSubject<CGPoint>()
    var conversationOffset: Observable<CGPoint> {
        return changeConversationOffset
            .asObservable()
    }

    // dataSourceTransition is used for the view to build DataSource, it change according to _dataSourceTransition - do not chnge it manually
    var dataSourceTransition: OWViewTransition = .reload
    fileprivate var _dataSourceTransition: BehaviorSubject<OWViewTransition> = BehaviorSubject(value: .reload)

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
        self.setupObservers()

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
                if self.errorsLoadingReplies[commentPresentationData.id] != nil {
                    cellOptions.append(OWConversationCellOption.commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel(
                        id: "\(commentPresentationData.id)_collapse",
                        data: commentPresentationData,
                        mode: .collapse,
                        depth: depth,
                        spacing: spacingBetweenComments
                    )))
                } else {
                    // This is expand in a reply or more in depth replies
                    cellOptions.append(OWConversationCellOption.commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel(
                        id: "\(commentPresentationData.id)_expand_only",
                        data: commentPresentationData,
                        mode: .expand,
                        depth: depth,
                        spacing: spacingBetweenComments
                    )))
                }
            default:
                cellOptions.append(OWConversationCellOption.commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel(
                    id: "\(commentPresentationData.id)_collapse",
                    data: commentPresentationData,
                    mode: .collapse,
                    depth: depth,
                    spacing: spacingBetweenComments
                )))

                cellOptions.append(contentsOf: getCommentCells(for: commentPresentationData.repliesPresentation))

                if self.errorsLoadingReplies[commentPresentationData.id] == nil,
                   repliesToShowCount < commentPresentationData.totalRepliesCount {
                    // This is expand more replies in root depth
                    cellOptions.append(OWConversationCellOption.commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel(
                        id: "\(commentPresentationData.id)_expand",
                        data: commentPresentationData,
                        mode: .expand,
                        depth: depth,
                        spacing: spacingBetweenComments
                    )))
                }
            }

            if self.errorsLoadingReplies[commentPresentationData.id] == .error {
                let cellOptionsError = self.getErrorStateCell(errorStateType: .loadConversationReplies(commentPresentationData: commentPresentationData), depth: depth)
                cellOptions.append(contentsOf: cellOptionsError)
            }

            if self.errorsLoadingReplies[commentPresentationData.id] == .reloading {
                cellOptions.append(contentsOf: self.getLoadingCell())
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

    func getErrorStateCell(errorStateType: OWErrorStateTypes, commentPresentationData: OWCommentPresentationData? = nil, depth: Int = 0) -> [OWConversationCellOption] {
        let errorViewModel = OWErrorStateCellViewModel(errorStateType: errorStateType, commentPresentationData: commentPresentationData, depth: depth)
        return [OWConversationCellOption.conversationErrorState(viewModel: errorViewModel)]
    }

    func getLoadingCell() -> [OWConversationCellOption] {
        return [OWConversationCellOption.loading(viewModel: OWLoadingCellViewModel())]
    }

    func getCommentsPresentationData(from response: OWConversationReadRM, isLoadingMoreReplies: Bool = false) -> [OWCommentPresentationData] {
        guard let responseComments = response.conversation?.comments else { return [] }

        let comments: [OWComment] = Array(responseComments)

        var commentsPresentationData = [OWCommentPresentationData]()
        var repliesPresentationData = [OWCommentPresentationData]()

        if !isLoadingMoreReplies {
            self.conversationPaginationOffset = response.conversation?.offset ?? 0
            self.conversationHasNext = response.conversation?.hasNext ?? false
        }

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
            let repliesPresentationData = commentPresentationData.repliesPresentation.first(where: { $0.id == replyId })
            existingRepliesPresentationData.append(
                OWCommentPresentationData(
                    id: replyId,
                    repliesIds: reply.replies?.map { $0.id }.unwrap() ?? [],
                    totalRepliesCount: reply.repliesCount ?? 0,
                    repliesOffset: reply.offset ?? 0,
                    repliesPresentation: repliesPresentationData?.repliesPresentation ?? []
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
            section: self.conversationData.article.additionalSettings.section),
                                      spacing: self.spacingBetweenComments)
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
}

fileprivate extension OWConversationViewViewModel {
    // swiftlint:disable function_body_length
    func setupObservers() {
        servicesProvider.activeArticleService().updateStrategy(conversationData.article.articleInformationStrategy)

        // Try again after error loading initial comments
        let tryAgainAfterInitialError = tryAgainAfterError
            .filter { $0 == .loadConversationComments }
            .voidify()
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self._dataSourceTransition.onNext(.reload)
                self._serverCommentsLoadingState.onNext(.loading(triggredBy: .tryAgainAfterError))
                self._shouldShowErrorLoadingComments.onNext(false)
                self.servicesProvider.timeMeasuringService().startMeasure(forKey: .conversationLoadingInitialComments)
            })
            .map { return OWLoadingTriggeredReason.tryAgainAfterError }
            .asObservable()

        // Subscribing to start realtime service
        Observable.merge(viewInitialized, tryAgainAfterInitialError.voidify())
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
                self._dataSourceTransition.onNext(.reload) // Block animations in the table view
                self._shouldShowErrorLoadingComments.onNext(false)
            })
            .flatMapLatest { [weak self] sortOption -> Observable<Event<OWConversationReadRM>> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                .netwokAPI()
                .conversation
                .conversationRead(mode: sortOption, page: OWPaginationPage.first, parentId: "", offset: 0)
                .response
                .materialize() // Required to keep the final subscriber even if errors arrived from the network
                .observe(on: self.conversationViewVMScheduler)
            }

        let conversationFetchedObservable = Observable.merge(viewInitializedObservable,
                                                             pullToRefreshObservable,
                                                             tryAgainAfterInitialError)
            .flatMapLatest { loadingTriggeredReason -> Observable<(Event<OWConversationReadRM>, OWLoadingTriggeredReason)> in
                return conversationReadObservable
                    .map { ($0, loadingTriggeredReason) }
            }
            .flatMapLatest({ [weak self] (event, loadingTriggeredReason) -> Observable<(Event<OWConversationReadRM>, OWLoadingTriggeredReason)> in
                // Add delay if end time for load initial comments is less then delayBeforeTryAgainAfterError
                guard let self = self else { return .empty() }
                let timeToLoadInitialComments = self.timeMeasuringMilliseconds(forKey: .conversationLoadingInitialComments)
                if case .error = event,
                   timeToLoadInitialComments < Metrics.delayBeforeTryAgainAfterError {
                    return Observable.just((event, loadingTriggeredReason))
                        .delay(.milliseconds(Metrics.delayBeforeTryAgainAfterError - timeToLoadInitialComments), scheduler: self.conversationViewVMScheduler)
                }
                return Observable.just((event, loadingTriggeredReason))
            })
            .map { [weak self] result -> (OWConversationReadRM, OWLoadingTriggeredReason)? in
                let event = result.0
                let loadingTriggeredReason = result.1
                guard let self = self else { return nil }
                self._dataSourceTransition.onNext(.reload) // Block animations in the table view
                switch event {
                case .next(let conversationRead):
                    // TODO: Clear any RX variables which affect error state in the View layer (like _shouldShowError).
                    self._serverCommentsLoadingState.onNext(.loading(triggredBy: loadingTriggeredReason))
                    self._shouldShowErrorLoadingComments.onNext(false)
                    self._shouldShowErrorLoadingMoreComments.onNext(false)
                    return (conversationRead, result.1)
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

        // First conversation load
        conversationFetchedObservable
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                // Send analytic event
                self.sendEvent(for: .fullConversationLoaded)
            })
            .disposed(by: disposeBag)

        // Each time the whole conversation loaded with new data except the first time
        conversationFetchedObservable
            .skip(1)
            .map { $0.1 }
            .subscribe(onNext: { [weak self] originalLoadingTriggeredReason in
                guard let self = self else { return }
                if originalLoadingTriggeredReason != .pullToRefresh {
                    self._scrollToTopAnimated.onNext(false)
                }
            })
            .disposed(by: disposeBag)

        // first load comments / refresh comments / sorted changed / try again after error
        conversationFetchedObservable
            .map { $0.0 }
            .observe(on: conversationViewVMScheduler)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }

                self.cacheConversationRead(response: response)
                let commentsPresentationData = self.getCommentsPresentationData(from: response)
                self._commentsPresentationData.replaceAll(with: commentsPresentationData)

                // Update loading state only after the presented comments are updated
                self._serverCommentsLoadingState.onNext(.notLoading)

                self._updateTableViewInstantly.onNext()
            })
            .disposed(by: disposeBag)

        // Realtime Indicator
        conversationFetchedObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.servicesProvider.realtimeIndicatorService().update(state: .enable)
            })
            .disposed(by: disposeBag)

        realtimeIndicationAnimationViewModel.outputs
            .realtimeIndicationViewModel.outputs
            .tapped
            .withLatestFrom(self.servicesProvider.realtimeIndicatorService().newComments)
            .subscribe(onNext: { [weak self] newComments in
                guard let self = self else { return }
                self.servicesProvider
                    .commentUpdaterService()
                    .update(.insert(comments: newComments), postId: self.postId)

                self.servicesProvider.realtimeIndicatorService().cleanCache()
            })
            .disposed(by: disposeBag)

        Observable.merge(sortOptionObservable.voidify(),
                         pullToRefreshObservable.voidify())
        .subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.errorsLoadingReplies.removeAll()
            self.servicesProvider.realtimeIndicatorService().update(state: .disable)
        })
        .disposed(by: disposeBag)

        // Set read only mode
        conversationFetchedObservable
            .map { $0.0 }
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
            .delay(.milliseconds(Metrics.delayBeforeReEnablingTableViewAnimation), scheduler: conversationViewVMScheduler)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self._dataSourceTransition.onNext(.animated)
            })
            .disposed(by: disposeBag)

        isReadOnly
            .bind(to: commentingCTAViewModel.inputs.isReadOnly)
            .disposed(by: disposeBag)

        isReadOnly
            .bind(to: conversationEmptyStateCellViewModel.outputs.conversationEmptyStateViewModel.inputs.isReadOnly)
            .disposed(by: disposeBag)

        shouldShowConversationEmptyState
            .bind(to: conversationEmptyStateCellViewModel.outputs.conversationEmptyStateViewModel.inputs.isEmpty)
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
            .map { $0.0 }
            .bind(to: communityQuestionCellViewModel.outputs.communityQuestionViewModel.inputs.conversationFetched)
            .disposed(by: disposeBag)

        // Try again after error loading more replies
        let tryAgainAfterLoadingMoreRepliesError = tryAgainAfterError
            .filter {
                if case .loadConversationReplies = $0 { return true }
                return false
            }
            .map { errorState -> OWCommentPresentationData? in
                switch errorState {
                case .loadConversationReplies(commentPresentationData: let commentPresentationData):
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

        let loadMoreRepliesReadObservable = Observable.merge(_loadMoreReplies, tryAgainAfterLoadingMoreRepliesError)
            .withLatestFrom(sortOptionObservable) { (commentPresentationData, sortOption) -> (OWCommentPresentationData, OWSortOption)  in
                return (commentPresentationData, sortOption)
            }
            .flatMap { [weak self] (commentPresentationData, sortOption) -> Observable<(OWCommentPresentationData, Event<OWConversationReadRM>?)> in
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

                self.servicesProvider.timeMeasuringService().startMeasure(forKey: .conversationLoadingMoreReplies(commentId: commentPresentationData.id))

                return self.servicesProvider
                    .netwokAPI()
                    .conversation
                    .conversationRead(mode: sortOption, page: .next, count: fetchCount, parentId: commentPresentationData.id, offset: commentPresentationData.repliesOffset)
                    .response
                    .materialize()
                    .observe(on: self.conversationViewVMScheduler)
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
                let timeToLoadMoreReplies = self.timeMeasuringMilliseconds(forKey: .conversationLoadingMoreReplies(commentId: commentPresentationData.id))
                if case .error = event,
                   timeToLoadMoreReplies < Metrics.delayBeforeTryAgainAfterError {
                    return Observable.just((commentPresentationData, event))
                        .delay(.milliseconds(Metrics.delayBeforeTryAgainAfterError - timeToLoadMoreReplies), scheduler: self.conversationViewVMScheduler)
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
                self._dataSourceTransition.onNext(.animated)
                if shouldShowErrorLoadingReplies {
                    self.errorsLoadingReplies[commentPresentationData.id] = .error
                    commentPresentationData.update.onNext()
                } else {
                    let existingRepliesPresentationData = self.getExistingRepliesPresentationData(for: commentPresentationData)

                    // add presentation data from response
                    var presentationDataFromResponse: [OWCommentPresentationData] = []
                    if let response = response {
                        self.cacheConversationRead(response: response)

                        presentationDataFromResponse = self.getCommentsPresentationData(from: response, isLoadingMoreReplies: true)

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
                    let countAfterUpdate = min(commentPresentationData.repliesPresentation.count + Metrics.defaultNumberOfReplies, commentPresentationData.totalRepliesCount)
                    repliesPresentation = Array(repliesPresentation.prefix(countAfterUpdate))

                    commentPresentationData.setRepliesPresentation(repliesPresentation)
                    commentPresentationData.update.onNext()
                }
            })
            .disposed(by: disposeBag)

        // Try again after error loading more comments
        let tryAgainAfterLoadingMoreError = tryAgainAfterError
            .filter { $0 == .loadMoreConversationComments }
            .withLatestFrom(_loadMoreComments)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self._dataSourceTransition.onNext(.animated)
                self._shouldShowErrorLoadingMoreComments.onNext(false)
                self._isLoadingMoreComments.onNext(true)
                self.servicesProvider.timeMeasuringService().startMeasure(forKey: .conversationLoadingMoreComments)
            })
            .observe(on: conversationViewVMScheduler)
            .asObservable()

        // fetch more comments
        let loadMoreCommentsReadObservable = Observable.merge(_loadMoreComments, tryAgainAfterLoadingMoreError)
            .observe(on: conversationViewVMScheduler)
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
                .observe(on: self.conversationViewVMScheduler)
            }

        let loadMoreCommentsReadFetched = loadMoreCommentsReadObservable
            .flatMapLatest({ [weak self] event -> Observable<Event<OWConversationReadRM>?> in
                // Add delay if end time for load more comments is less then delayBeforeTryAgainAfterError
                guard let self = self else { return Observable.just(event) }
                let timeToLoadMoreComments = self.timeMeasuringMilliseconds(forKey: .conversationLoadingMoreComments)
                if case .error = event,
                   timeToLoadMoreComments < Metrics.delayBeforeTryAgainAfterError {
                    return Observable.just(event)
                        .delay(.milliseconds(Metrics.delayBeforeTryAgainAfterError - timeToLoadMoreComments), scheduler: self.conversationViewVMScheduler)
                }
                return Observable.just(event)
            })
            .map { [weak self] event -> OWConversationReadRM? in
                guard let self = self else { return nil }
                self._isLoadingMoreComments.onNext(false)
                switch event {
                case .next(let conversationRead):
                    // TODO: Clear any RX variables which affect error state in the View layer (like _shouldShowError).
                    return conversationRead
                case .error(_):
                    // TODO: handle error - update the UI state for showing error in the View layer
                    self._dataSourceTransition.onNext(.reload)
                    self._shouldShowErrorLoadingMoreComments.onNext(true)
                    return nil
                default:
                    return nil
                }
            }
            .unwrap()

        // append new comments on load more
        loadMoreCommentsReadFetched
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
            .delay(.milliseconds(Metrics.delayForPerformGuidelinesViewAnimation), scheduler: conversationViewVMScheduler)
            .bind(to: _performTableViewAnimation)
            .disposed(by: disposeBag)

        // Responding to comment height change (for updating cell) and tableView height change for errorState cell
        cellsViewModels
            .flatMapLatest { cellsVms -> Observable<Void> in
                let sizeChangeObservable: [Observable<Void>] = cellsVms.map { vm in
                    if case.comment(let commentCellViewModel) = vm {
                        let commentVM = commentCellViewModel.outputs.commentVM
                        return commentVM.outputs.heightChanged
                    }
                    return nil
                }
                .unwrap()
                return Observable.merge(sizeChangeObservable)
            }
            // This debounce makes sure performTableViewAnimation is done once per new
            // cells that are loaded in new replies or new loaded comments
            // fixes scroll jumps in the tableView
            .debounce(.milliseconds(Metrics.debouncePerformTableViewAnimation), scheduler: conversationViewVMScheduler)
            .bind(to: _performTableViewAnimation)
            .disposed(by: disposeBag)

        // Responding to errorState cell with tableViewHeight change
        Observable.combineLatest(cellsViewModels, tableViewHeightChanged)
            .flatMapLatest { (cellsVms, tableViewHeight) -> Observable<Void> in
                let sizeChangeObservable: [Observable<Void>] = cellsVms.map { cellVM in
                    if case.conversationErrorState(let errorStateCellViewModeling) = cellVM {
                        let errorStateVM = errorStateCellViewModeling.outputs.errorStateViewModel
                        if errorStateVM.outputs.errorStateType == .loadConversationComments {
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
            .delay(.milliseconds(Metrics.delayForPerformTableViewAnimationErrorState), scheduler: conversationViewVMScheduler)
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
            .map { OWCommentCreationTypeInternal.replyToComment(originComment: $0) }
            .bind(to: commentCreationTap)
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
            .observe(on: conversationViewVMScheduler)
            .subscribe(onNext: { [weak self] commentPresentationData, mode in
                guard let self = self else { return }
                self._dataSourceTransition.onNext(.animated)
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

        // Reload OWCommentThreadActionsCell at index
        loadMoreRepliesReadUpdated
            .delay(.milliseconds(Metrics.delayUpdateTableAfterLoadedReplies), scheduler: conversationViewVMScheduler)
            .map { (commentPresentationData, _, _) -> OWCommentPresentationData in
                return commentPresentationData
            }
            .withLatestFrom(cellsViewModels) { ($0, $1) }
            .map { (commentPresentationData, cellsViewModels) -> (OWConversationCellOption, Int)? in
                let cellOption = cellsViewModels.first(where: {
                    guard let viewModel = $0.viewModel as? OWCommentThreadActionsCellViewModel else { return false }
                    return viewModel.commentPresentationData.id == commentPresentationData.id && viewModel.mode == .expand
                })
                let cellIndex = cellsViewModels.firstIndex(where: {
                    guard let viewModel = $0.viewModel as? OWCommentThreadActionsCellViewModel else { return false }
                    return viewModel.commentPresentationData.id == commentPresentationData.id && viewModel.mode == .expand
                })
                guard let cellOption = cellOption, let cellIndex = cellIndex else { return nil }
                return (cellOption, cellIndex)
            }
            .unwrap()
            .do(onNext: { (cellOption, _) in
                guard let viewModel = cellOption.viewModel as? OWCommentThreadActionsCellViewModel else { return }
                viewModel.outputs.commentActionsVM.inputs.isLoading.onNext(false)
            })
            .map { (_, cellIndex) -> Int in
                return cellIndex
            }
            .bind(to: _reloadCellIndex)
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

        // Observe tableview will display cell to load more comments
        willDisplayCell
            .filter { _ in self.conversationHasNext }
            .withLatestFrom(shouldShowErrorLoadingMoreComments) { ($0, $1) }
            .filter { !$1 }
            .map { (willDisplayCellEvent, _) -> Int in
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
                self.sendEvent(for: .loadMoreComments(paginationOffset: self.conversationPaginationOffset))
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self._isLoadingMoreComments.onNext(true)
                self._loadMoreComments.onNext(self.conversationPaginationOffset)
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

        // Dynamic should update tableView cells

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .flatMapLatest {
                return OWSharedServicesProvider.shared.appLifeCycle()
                    .isActive
                    .filter { $0 }
                    .take(1)
            }
            .delay(.milliseconds(Metrics.delayForPerformTableViewAnimationAfterContentSizeChanged), scheduler: conversationViewVMScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self._performTableViewAnimation.onNext()
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
            .observe(on: MainScheduler.instance)
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
                    self._serverCommentsLoadingState.onNext(.loading(triggredBy: .sortingChanged))
                    let sortDictateService = self.servicesProvider.sortDictateService()
                    sortDictateService.update(sortOption: newSort, perPostId: self.postId)

                    // Remove all comments to show skeletons while loading new comments according to the new sort
                    self._commentsPresentationData.removeAll()

                    self.servicesProvider.lastCommentTypeInMemoryCacheService().remove(forKey: self.postId)
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

        let updatedCommentsObservable = self.servicesProvider.commentUpdaterService()
            .getUpdatedComments(for: postId)
            .flatMap { [weak self] updateType -> Observable<OWCommentUpdateType> in
                guard let self = self else { return .empty() }

                // Waiting for a state in which we are not loading or showing error before updating/adding comments or replies from a local service
                return Observable.combineLatest(self.serverCommentsLoadingState,
                                                self.shouldShowErrorLoadingComments) { loadingState, shouldShowError in
                    return (loadingState == .notLoading && !shouldShowError)
                }
                .filter { $0 }
                .take(1)
                .map { _ in updateType }
            }

        updatedCommentsObservable
            .delay(.milliseconds(Metrics.delayAfterRecievingUpdatedComments), scheduler: conversationViewVMScheduler)
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
                self._scrollToTopAnimated.onNext(true)
            })
            .flatMapLatest { [weak self] comments -> Observable<[OWComment]> in
                guard let self = self else { return .empty() }
                // waiting for scroll to top
                return self.scrolledToTop
                    .take(1)
                    .map { _ in comments }
            }
            .delay(.milliseconds(Metrics.delayAfterScrolledToTopAnimated), scheduler: conversationViewVMScheduler)
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
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self._shouldShowErrorCommentDelete.onNext(false)
            })
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
                    .observe(on: self.conversationViewVMScheduler)
            }
            .map { [weak self] event -> OWCommentDelete? in
                guard let self = self else { return nil }
                switch event {
                case .next(let commentDelete):
                    // TODO: Clear any RX variables which affect error state in the View layer (like _shouldShowError).
                    return commentDelete
                case .error(_):
                    // TODO: handle error - update something like _shouldShowError RX variable which affect the UI state for showing error in the View layer
                    self._shouldShowErrorCommentDelete.onNext(true)
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
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                // 1. Triggering authentication UI if needed
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().ifNeededTriggerAuthenticationUI(for: .mutingUser)
                    .voidify()
            }
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                // 2. Waiting for authentication required for muting user
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().waitForAuthentication(for: .mutingUser)
            }
            .filter { $0 }
            .flatMapLatest { [weak self] _ -> Observable<OWRxPresenterResponseType> in
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
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self._shouldShowErrorMuteUser.onNext(false)
            })
            .flatMap { [weak self] userId -> Observable<Event<EmptyDecodable>> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                    .netwokAPI()
                    .user
                    .mute(userId: userId)
                    .response
                    .materialize()
                    .observe(on: self.conversationViewVMScheduler)
            }
            .map { [weak self] event -> Bool in
                guard let self = self else { return false }
                switch event {
                case .next:
                    // TODO: Clear any RX variables which affect error state in the View layer (like _shouldShowError).
                    return true
                case .error(_):
                    // TODO: handle error - update something like _shouldShowError RX variable which affect the UI state for showing error in the View layer
                    self._shouldShowErrorMuteUser.onNext(true)
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

            pullToRefresh
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.servicesProvider.lastCommentTypeInMemoryCacheService().remove(forKey: self.postId)
                })
                .disposed(by: disposeBag)

            servicesProvider
                .activeArticleService()
                .articleExtraData
                .subscribe(onNext: { [weak self] article in
                    self?.articleUrl = article.url.absoluteString
                })
                .disposed(by: disposeBag)

        let scrollToLastCellErrorLoadingMore = shouldShowErrorLoadingMoreComments
            .filter { $0 }
            .voidify()
            .asObservable()

        let scrollToBottomAfterErrorLoadingMore = tryAgainAfterError
            .filter { $0 == .loadMoreConversationComments }
            .voidify()

        let scrollToLastCellWithDelay = Observable.merge(scrollToLastCellErrorLoadingMore, scrollToBottomAfterErrorLoadingMore)
            .delay(.milliseconds(Metrics.delayBeforeScrollingToLastCell), scheduler: conversationViewVMScheduler)

        // Scroll to last cell only if tableView is scrolled to bottom
        Observable.merge(scrollToLastCellWithDelay)
            .observe(on: MainScheduler.instance)
            .withLatestFrom(tableViewHeightChanged)
            .withLatestFrom(tableViewContentSizeHeightChanged) { ($0, $1) }
            .withLatestFrom(tableViewContentOffsetYChanged) { ($0.0, $0.1, $1) }
            .filter { tableViewHeight, tableViewContentSizeHeight, tableViewContentOffsetY in
                return tableViewContentOffsetY + tableViewHeight + Metrics.scrollUpThresholdForCancelScrollToLastCell > tableViewContentSizeHeight
            }
            .withLatestFrom(cellsViewModels)
            .map { $0.count - 1 }
            .bind(to: _scrollToCellIndex)
            .disposed(by: disposeBag)

        _dataSourceTransition
            .subscribe(onNext: { [weak self] transition in
                self?.dataSourceTransition = transition
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
