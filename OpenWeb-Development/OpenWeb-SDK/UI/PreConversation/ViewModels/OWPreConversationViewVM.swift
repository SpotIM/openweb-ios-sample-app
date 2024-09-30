//
//  OWPreConversationViewVM.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 29/08/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

// swiftlint:disable file_length

// Our sections is just a string as we will flat all the comments, replies, ads and everything into cells
typealias PreConversationDataSourceModel = OWAnimatableSectionModel<String, OWPreConversationCellOption>

protocol OWPreConversationViewViewModelingInputs {
    var fullConversationTap: PublishSubject<Void> { get }
    var fullConversationCTATap: PublishSubject<Void> { get }
    var commentCreationTap: PublishSubject<OWCommentCreationTypeInternal> { get }
    var viewInitialized: PublishSubject<Void> { get }
    var tableViewSize: PublishSubject<CGSize> { get }
    var dismissToast: PublishSubject<Void> { get }
}

protocol OWPreConversationViewViewModelingOutputs {
    var viewAccessibilityIdentifier: String { get }
    var filterTabsVM: OWFilterTabsViewViewModeling { get }
    var preConversationSummaryVM: OWPreConversationSummaryViewModeling { get }
    var loginPromptViewModel: OWLoginPromptViewModeling { get }
    var communityGuidelinesViewModel: OWCommunityGuidelinesViewModeling { get }
    var communityQuestionViewModel: OWCommunityQuestionViewModeling { get }
    var realtimeIndicationAnimationViewModel: OWRealtimeIndicationAnimationViewModeling { get }
    var commentingCTAViewModel: OWCommentingCTAViewModeling { get }
    var footerViewViewModel: OWPreConversationFooterViewModeling { get }
    var errorStateViewModel: OWErrorStateViewViewModeling { get }
    var preConversationDataSourceSections: Observable<[PreConversationDataSourceModel]> { get }
    var openFullConversation: Observable<Void> { get }
    var openCommentCreation: Observable<OWCommentCreationTypeInternal> { get }
    var performTableViewAnimation: Observable<Void> { get }
    var urlClickedOutput: Observable<URL> { get }
    var summaryTopPadding: Observable<CGFloat> { get }
    var shouldShowCommentingCTAView: Observable<Bool> { get }
    var shouldShowComments: Observable<Bool> { get }
    var shouldShowCTAButton: Observable<Bool> { get }
    var shouldShowErrorLoadingComments: Observable<Bool> { get }
    var shouldShowFooter: Observable<Bool> { get }
    var shouldShowComapactView: Bool { get }
    var conversationCTAButtonTitle: Observable<String> { get }
    var shouldAddContentTapRecognizer: Bool { get }
    var isCompactBackground: Bool { get }
    var compactCommentVM: OWPreConversationCompactContentViewModeling { get }
    var openProfile: Observable<OWOpenProfileType> { get }
    var openReportReason: Observable<OWCommentViewModeling> { get }
    var openClarityDetails: Observable<OWClarityDetailsRequireData> { get }
    var openCommentThread: Observable<(OWCommentId, OWCommentThreadPerformActionType)> { get }
    var commentId: Observable<String> { get }
    var parentId: Observable<String> { get }
    var dataSourceTransition: OWViewTransition { get }
    var displayToast: Observable<OWToastNotificationCombinedData> { get }
    var hideToast: Observable<Void> { get }
    var tableViewSizeChanged: Observable<CGSize> { get }
    var shouldShowFilterTabsView: Observable<Bool> { get }
}

protocol OWPreConversationViewViewModeling: AnyObject {
    var inputs: OWPreConversationViewViewModelingInputs { get }
    var outputs: OWPreConversationViewViewModelingOutputs { get }
}

class OWPreConversationViewViewModel: OWPreConversationViewViewModeling,
                                      OWPreConversationViewViewModelingInputs,
                                      OWPreConversationViewViewModelingOutputs {
    fileprivate struct Metrics {
        static let delayForPerformTableViewAnimation: Int = 10 // ms
        static let delayForUICellUpdate: Int = 100 // ms
        static let viewAccessibilityIdentifier = "pre_conversation_view_@_style_id"
        static let delayBeforeReEnablingTableViewAnimation: Int = 200 // ms
        static let delayBeforeTryAgainAfterError: Int = 2000 // ms
        static let delayAfterRecievingUpdatedComments: Int = 200 // ms
    }

    var inputs: OWPreConversationViewViewModelingInputs { return self }
    var outputs: OWPreConversationViewViewModelingOutputs { return self }

    fileprivate let preConversationViewVMScheduler: SchedulerType = SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: "preConversationViewVMScheduler")

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let imageProvider: OWImageProviding
    fileprivate let preConversationData: OWPreConversationRequiredData
    fileprivate let viewableMode: OWViewableMode
    let filterTabsVM: OWFilterTabsViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate let _updateLocalComment = PublishSubject<(OWComment, OWCommentId)>()

    fileprivate var articleUrl: String = ""

    var _cellsViewModels = OWObservableArray<OWPreConversationCellOption>()
    fileprivate var cellsViewModels: Observable<[OWPreConversationCellOption]> {
        return _cellsViewModels
            .rx_elements()
            .asObservable()
    }

    fileprivate let _serverCommentsLoadingState = BehaviorSubject<OWLoadingState>(value: .loading(triggredBy: .initialLoading))
    fileprivate var serverCommentsLoadingState: Observable<OWLoadingState> {
        _serverCommentsLoadingState
            .asObservable()
    }

    var tableViewSize = PublishSubject<CGSize>()
    lazy var tableViewSizeChanged: Observable<CGSize> = {
        tableViewSize
            .distinctUntilChanged()
            .asObservable()
    }()

    var preConversationDataSourceSections: Observable<[PreConversationDataSourceModel]> {
        return cellsViewModels
            .map { items in
                // TODO: We might decide to work with few sections in the future.
                // Current implementation will be one section.
                // The String can be the `postId` which we will add once the VM will be ready.
                let section = PreConversationDataSourceModel(model: "postId", items: items)
                return [section]
            }
    }

    lazy var viewAccessibilityIdentifier: String = {
        let styleId = (preConversationData.settings.preConversationSettings.style).styleIdentifier
        return Metrics.viewAccessibilityIdentifier.replacingOccurrences(of: "@", with: styleId)
    }()

    lazy var preConversationSummaryVM: OWPreConversationSummaryViewModeling = {
        return OWPreConversationSummaryViewModel(style: preConversationStyle.preConversationSummaryStyle)
    }()

    lazy var loginPromptViewModel: OWLoginPromptViewModeling = {
        return OWLoginPromptViewModel(isFeatureEnabled: preConversationStyle.isLoginPromptEnabled, style: .left)
    }()

    lazy var communityGuidelinesViewModel: OWCommunityGuidelinesViewModeling = {
        return OWCommunityGuidelinesViewModel(style: preConversationStyle.communityGuidelinesStyle,
                                              spacing: preConversationStyle.spacing.communityGuidelines)
    }()

    lazy var communityQuestionViewModel: OWCommunityQuestionViewModeling = {
        return OWCommunityQuestionViewModel(style: preConversationStyle.communityQuestionStyle,
                                            spacing: preConversationStyle.spacing.communityQuestions)
    }()

    lazy var realtimeIndicationAnimationViewModel: OWRealtimeIndicationAnimationViewModeling = {
        return OWRealtimeIndicationAnimationViewModel()
    }()

    lazy var commentingCTAViewModel: OWCommentingCTAViewModeling = {
        return OWCommentingCTAViewModel(imageProvider: imageProvider)
    }()

    lazy var footerViewViewModel: OWPreConversationFooterViewModeling = {
        return OWPreConversationFooterViewModel()
    }()

    lazy var errorStateViewModel: OWErrorStateViewViewModeling = {
        return OWErrorStateViewViewModel(errorStateType: .loadConversationComments)
    }()

    fileprivate lazy var preConversationStyle: OWPreConversationStyle = {
        return self.preConversationData.settings.preConversationSettings.style
    }()

    fileprivate lazy var isCompactMode: Bool = {
        if case .compact = preConversationStyle {
            return true
        }
        return false
    }()

    fileprivate lazy var _preConversationStyle: BehaviorSubject<OWPreConversationStyle> = {
        return BehaviorSubject<OWPreConversationStyle>(value: preConversationStyle)
    }()
    fileprivate lazy var preConversationStyleObservable: Observable<OWPreConversationStyle> = {
        return _preConversationStyle
            .share(replay: 1)
    }()

    fileprivate lazy var isReadOnlyLocalSetting: Bool = {
        return preConversationData.article.additionalSettings.readOnlyMode == .enable
    }()
    fileprivate lazy var _isReadOnly = BehaviorSubject<Bool>(value: isReadOnlyLocalSetting)
    fileprivate lazy var isReadOnlyObservable: Observable<Bool> = {
        return _isReadOnly
            .share(replay: 1)
    }()

    fileprivate var tryAgainAfterError = PublishSubject<OWErrorStateTypes>()

    lazy var compactCommentVM: OWPreConversationCompactContentViewModeling = {
        return OWPreConversationCompactContentViewModel(imageProvider: imageProvider)
    }()

    fileprivate lazy var commentsCountObservable: Observable<String> = {
        return OWSharedServicesProvider.shared.realtimeService().realtimeData
            .map { [weak self] realtimeData in
                guard let self = self,
                      let count = realtimeData.data?.totalCommentsCount(forPostId: self.postId) else {return nil}
                return count
            }
            .unwrap()
            .map { count in
                return count > 0 ? "(\(count.kmFormatted))" : ""
            }
            .asObservable()
    }()

    var conversationCTAButtonTitle: Observable<String> {
        Observable.combineLatest(commentsCountObservable, preConversationStyleObservable, isReadOnlyObservable, isEmpty) { count, style, isReadOnly, isEmpty in
            switch(style) {
            case .regular, .custom:
                return OWLocalizationManager.shared.localizedString(key: "ShowMoreComments")
            case .compact:
                return nil
            case .ctaButtonOnly:
                if isEmpty {
                    return OWLocalizationManager.shared.localizedString(key: "PostAComment")
                } else {
                    return OWLocalizationManager.shared.localizedString(key: "ShowComments") + " \(count)"
                }
            case .ctaWithSummary:
                if !isEmpty {
                    return OWLocalizationManager.shared.localizedString(key: "ShowComments")
                } else if !isReadOnly {
                    return OWLocalizationManager.shared.localizedString(key: "PostAComment")
                }
            }
            return nil
        }
        .unwrap()
        .startWith(initialCtaTitle)
    }

    fileprivate lazy var initialCtaTitle: String = {
        switch preConversationStyle {
        case .regular, .custom:
            return OWLocalizationManager.shared.localizedString(key: "ShowMoreComments")
        case .compact:
            return ""
        case .ctaButtonOnly, .ctaWithSummary:
            return OWLocalizationManager.shared.localizedString(key: "ShowComments")
        }
    }()

    var fullConversationTap = PublishSubject<Void>()
    var fullConversationCTATap = PublishSubject<Void>()

    fileprivate lazy var realtimeIndicationTapped: Observable<Void> = {
        return realtimeIndicationAnimationViewModel.outputs
            .realtimeIndicationViewModel.outputs
            .tapped
            .asObservable()
    }()

    var filterTabOpenConversation: Observable<Void> {
        return filterTabsVM.outputs.didSelectTab
            .voidify()
            .asObservable()
    }

    var openFullConversation: Observable<Void> {
        return Observable.merge(fullConversationTap,
                                fullConversationCTATap,
                                realtimeIndicationTapped,
                                filterTabOpenConversation)
            .asObservable()
    }

    fileprivate var _openProfile = PublishSubject<OWOpenProfileType>()
    var openProfile: Observable<OWOpenProfileType> {
        return _openProfile
            .asObservable()
    }

    fileprivate var _openCommentThread = PublishSubject<(OWCommentId, OWCommentThreadPerformActionType)>()
    var openCommentThread: Observable<(OWCommentId, OWCommentThreadPerformActionType)> {
        _openCommentThread
            .asObservable()
    }

    fileprivate var openReportReasonChange = PublishSubject<OWCommentViewModeling>()
    var openReportReason: Observable<OWCommentViewModeling> {
        return openReportReasonChange
            .asObservable()
    }

    fileprivate var openClarityDetailsChange = PublishSubject<OWClarityDetailsRequireData>()
    var openClarityDetails: Observable<OWClarityDetailsRequireData> {
        return openClarityDetailsChange
            .asObservable()
    }

    fileprivate var commentIdChange = PublishSubject<String>()
    var commentId: Observable<String> {
        return commentIdChange
            .asObservable()
    }

    fileprivate var parentIdChange = PublishSubject<String>()
    var parentId: Observable<String> {
        return parentIdChange
            .asObservable()
    }

    var commentCreationTap = PublishSubject<OWCommentCreationTypeInternal>()
    var openCommentCreation: Observable<OWCommentCreationTypeInternal> {
        return commentCreationTap
            .asObservable()
    }

    fileprivate var _performTableViewAnimation = PublishSubject<Void>()
    var performTableViewAnimation: Observable<Void> {
        return _performTableViewAnimation
            .asObservable()
    }

    var dismissToast = PublishSubject<Void>()

    fileprivate var _displayToast = PublishSubject<OWToastNotificationCombinedData?>()
    var displayToast: Observable<OWToastNotificationCombinedData> {
        return _displayToast
            .unwrap()
            .asObservable()
    }
    var hideToast: Observable<Void> {
        return _displayToast
            .filter { $0 == nil }
            .voidify()
            .asObservable()
    }

    fileprivate var _urlClick = PublishSubject<URL>()
    var urlClickedOutput: Observable<URL> {
        return _urlClick
            .asObservable()
    }

    fileprivate var deleteComment = PublishSubject<OWCommentViewModeling>()
    fileprivate var muteCommentUser = PublishSubject<OWCommentViewModeling>()
    fileprivate var retryMute = PublishSubject<Void>()

    var viewInitialized = PublishSubject<Void>()
    fileprivate lazy var viewInitializedObservable: Observable<OWLoadingTriggeredReason> = {
        return viewInitialized
            .map { OWLoadingTriggeredReason.initialLoading }
    }()

    var summaryTopPadding: Observable<CGFloat> {
       preConversationStyleObservable
            .map { style in
                switch(style) {
                case .ctaButtonOnly:
                    return 0
                case .compact:
                    return OWPreConversationView.Metrics.compactSummaryTopPadding
                case .ctaWithSummary, .regular, .custom:
                    return OWPreConversationView.Metrics.summaryTopPadding
                }
            }
    }

    var shouldShowComments: Observable<Bool> {
        Observable.combineLatest(preConversationStyleObservable, isEmpty, shouldShowErrorLoadingComments) { style, isEmpty, isError in
            switch(style) {
            case .regular, .custom:
                return !isEmpty && !isError
            case .compact, .ctaWithSummary, .ctaButtonOnly:
                return false
            }
        }
        .observe(on: MainScheduler.instance)
    }

    fileprivate var _shouldShowErrorLoadingComments = BehaviorSubject<Bool>(value: false)
    var shouldShowErrorLoadingComments: Observable<Bool> {
        return Observable.combineLatest(_shouldShowErrorLoadingComments.asObservable(), preConversationStyleObservable) { showError, style in
            guard style.isLoadingErrorEnabled else { return false }
            return showError
        }
        .share(replay: 1)
    }

    var shouldShowComapactView: Bool {
        return isCompactMode
    }

    fileprivate var _shouldShowCTAButton = BehaviorSubject<Bool>(value: true)
    var shouldShowCTAButton: Observable<Bool> {
        Observable.combineLatest(_shouldShowCTAButton,
                                 preConversationStyleObservable,
                                 isReadOnlyObservable,
                                 isEmpty) { shouldShow, style, isReadOnly, isEmpty in
            guard shouldShow else { return false }
            var isVisible = true
            switch (style) {
            case .regular, .custom:
                isVisible = !isEmpty
            case .ctaButtonOnly, .ctaWithSummary:
                isVisible = !isEmpty || !isReadOnly
            case .compact:
                isVisible = false
            }
            return isVisible
        }
    }

    var shouldShowCommentingCTAView: Observable<Bool> {
        Observable.combineLatest(
            preConversationStyleObservable,
            isReadOnlyObservable,
            isEmpty,
            shouldShowErrorLoadingComments
        ) { style, isReadOnly, isEmpty, shouldShowErrorLoadingComments in
            guard shouldShowErrorLoadingComments == false else { return false }
            switch (style) {
            case .regular, .custom:
                return true
            case .compact:
                return false
            case .ctaWithSummary, .ctaButtonOnly:
                return isReadOnly && isEmpty
            }
        }
    }

    var shouldShowFooter: Observable<Bool> { // TODO: will get from config
        preConversationStyleObservable
            .map { style in
                switch(style) {
                case .compact:
                    return false
                default:
                    return true
                }
            }
    }

    // Show FilterTabsView
    lazy var shouldShowFilterTabsView: Observable<Bool> = {
        guard preConversationStyle != .ctaButtonOnly else { return Observable.just(false) }
        return filterTabsVM.outputs.shouldShowFilterTabs
    }()

    lazy var shouldAddContentTapRecognizer: Bool = {
        return isCompactMode
    }()

    lazy var isCompactBackground: Bool = {
        return isCompactMode
    }()

    fileprivate var isEmpty = BehaviorSubject<Bool>(value: false)

    fileprivate var postId: OWPostId {
        return OWManager.manager.postId ?? ""
    }

    fileprivate var _forceRefresh = PublishSubject<Void>()
    fileprivate lazy var refreshConversationObservable: Observable<OWLoadingTriggeredReason> = {
        return Observable.merge(
            _forceRefresh.map { OWLoadingTriggeredReason.forceRefresh }
        )
        .asObservable()
    }()

    var dataSourceTransition: OWViewTransition = .reload

    init (
        servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
        imageProvider: OWImageProviding = OWCloudinaryImageProvider(),
        preConversationData: OWPreConversationRequiredData,
        viewableMode: OWViewableMode) {
            self.servicesProvider = servicesProvider
            self.imageProvider = imageProvider
            self.preConversationData = preConversationData
            self.viewableMode = viewableMode
            self.filterTabsVM = OWFilterTabsViewViewModel(servicesProvider: servicesProvider,
                                                          sourceType: .preConversation)
            self.populateInitialUI()
            setupObservers()

            sendEvent(for: .preConversationViewed)
    }
}

fileprivate extension OWPreConversationViewViewModel {
    // swiftlint:disable function_body_length
    func setupObservers() {
        servicesProvider.activeArticleService().updateStrategy(preConversationData.article.articleInformationStrategy)

        servicesProvider.toastNotificationService()
            .toastToShow
            .observe(on: MainScheduler.instance)
            .bind(to: _displayToast)
            .disposed(by: disposeBag)

        // Try again after error loading initial comments
        let tryAgainAfterInitialError = tryAgainAfterError
            .filter { $0 == .loadConversationComments }
            .voidify()
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.dataSourceTransition = .reload
                self._serverCommentsLoadingState.onNext(.loading(triggredBy: .tryAgainAfterError))
                self._shouldShowErrorLoadingComments.onNext(false)
                self.servicesProvider.timeMeasuringService().startMeasure(forKey: .preConversationLoadingInitialComments)
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

        // Realtime Indicator
        realtimeIndicationTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let sortDictateService = self.servicesProvider.sortDictateService()
                sortDictateService.update(sortOption: .newest, perPostId: self.postId)

                self.servicesProvider.realtimeService().stopFetchingData()
                self.servicesProvider.realtimeIndicatorService().update(state: .disable)
            })
            .disposed(by: disposeBag)

        let realtimeIndicatorUpdateStateObservable = Observable.combineLatest(viewInitialized,
                                                                              preConversationStyleObservable) { _, style -> Bool in
            switch(style) {
            case .regular, .custom:
                return true
            case .compact, .ctaButtonOnly, .ctaWithSummary:
                return false
            }
        }
            .map { shouldShow -> OWRealtimeIndicatorState in
                return shouldShow ? .enable : .disable
            }

        realtimeIndicatorUpdateStateObservable
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                self.servicesProvider.realtimeIndicatorService().update(state: state)
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
            .flatMapLatest { [weak self] sortOption -> Observable<OWConversationReadRM> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                .networkAPI()
                .conversation
                .conversationRead(mode: sortOption, page: OWPaginationPage.first)
                .response
            }

        let conversationFetchedObservable = Observable.merge(
            viewInitializedObservable,
            tryAgainAfterInitialError,
            refreshConversationObservable
        )
            .flatMapLatest { loadingTriggeredReason -> Observable<(Event<OWConversationReadRM>, OWLoadingTriggeredReason)> in
                return conversationReadObservable
                    .materialize() // Required to keep the final subscriber even if errors arrived from the network
                    .map { ($0, loadingTriggeredReason) }
            }
            .flatMapLatest({ [weak self] (event, loadingTriggeredReason) -> Observable<(Event<OWConversationReadRM>, OWLoadingTriggeredReason)> in
                // Add delay if end time for load initial comments is less then delayBeforeTryAgainAfterError
                guard let self = self else { return .empty() }
                let timeToLoadInitialComments = self.servicesProvider.timeMeasuringService()
                    .timeMeasuringMilliseconds(forKey: .preConversationLoadingInitialComments,
                                               delayDuration: Metrics.delayBeforeTryAgainAfterError)
                if case .error = event,
                   timeToLoadInitialComments < Metrics.delayBeforeTryAgainAfterError {
                    return Observable.just((event, loadingTriggeredReason))
                        .delay(.milliseconds(Metrics.delayBeforeTryAgainAfterError - timeToLoadInitialComments), scheduler: self.preConversationViewVMScheduler)
                }
                return Observable.just((event, loadingTriggeredReason))
            })
            .map { [weak self] result -> OWConversationReadRM? in
                guard let self = self else { return nil }
                let event = result.0
                switch event {
                case .next(let conversationRead):
                    // TODO: Clear any RX variables which affect error state in the View layer (like _shouldShowError).
                    self._shouldShowErrorLoadingComments.onNext(false)
                    return conversationRead
                case .error(_):
                    // TODO: handle error - update something like _shouldShowError RX variable which affect the UI state for showing error in the View layer
                    self._shouldShowErrorLoadingComments.onNext(true)
                    self._serverCommentsLoadingState.onNext(.notLoading)
                    return nil
                default:
                    return nil
                }
            }
            .unwrap()
            .share()

        // Creating the cells VMs for the pre conversation
        // Do so only for designs which requiring a table view
        conversationFetchedObservable
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return !self.isNonTableViewStyle(self.preConversationStyle)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                guard
                    let self = self,
                    let responseComments = response.conversation?.comments,
                    let responseUsers = response.conversation?.users
                else { return }
                var viewModels = [OWPreConversationCellOption]()

                let numOfComments = self.preConversationStyle.numberOfComments
                let comments: [OWComment] = Array(responseComments.prefix(numOfComments))

                // Hide the "Show More Comments" button, if there are fewer comments than num of comments in  PreConversation style
                self._shouldShowCTAButton.onNext(numOfComments < responseComments.count)

                // cache comments in comment service
                self.servicesProvider.commentsService().set(comments: responseComments, postId: self.postId)

                // cache users in users service
                self.servicesProvider.usersService().set(users: responseUsers)

                // cache reported comments in reported comments service
                self.servicesProvider.reportedCommentsService().updateReportedComments(forConversationResponse: response, postId: self.postId)

                for (index, comment) in comments.enumerated() {
                    guard let user = responseUsers[comment.userId ?? ""] else { return }

                    let reportedCommentsService = self.servicesProvider.reportedCommentsService()
                    let commentWithUpdatedStatus = reportedCommentsService.getUpdatedComment(for: comment, postId: self.postId)

                    let hasReplies: Bool = (commentWithUpdatedStatus.totalRepliesCount ?? 0) > 0
                    let vm = OWCommentCellViewModel(data: OWCommentRequiredData(
                        comment: commentWithUpdatedStatus,
                        user: user,
                        replyToUser: nil,
                        collapsableTextLineLimit: self.preConversationStyle.collapsableTextLineLimit,
                        section: self.preConversationData.article.additionalSettings.section),
                                                    spacing: hasReplies ? self.preConversationStyle.spacing.commentSpacingWithThread : self.preConversationStyle.spacing.betweenComments)
                    viewModels.append(OWPreConversationCellOption.comment(viewModel: vm))

                    if hasReplies {
                        let presentationData = OWCommentPresentationData(
                            id: commentWithUpdatedStatus.id ?? "",
                            repliesIds: commentWithUpdatedStatus.replies?.map { $0.id }.unwrap() ?? [],
                            totalRepliesCount: commentWithUpdatedStatus.repliesCount ?? 0,
                            repliesOffset: commentWithUpdatedStatus.offset ?? 0,
                            repliesPresentation: [])

                        viewModels.append(OWPreConversationCellOption.commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel(
                            id: "\(presentationData.id)_openThread",
                            data: presentationData,
                            mode: .openCommentThread,
                            depth: 0,
                            spacing: self.preConversationStyle.spacing.threadActionSpacing
                        )))
                    }

                    if (index < comments.count - 1) {
                        viewModels.append(OWPreConversationCellOption.spacer(viewModel: OWSpacerCellViewModel(style: .comment)))
                    }
                }
                self._cellsViewModels.removeAll()
                self._cellsViewModels.append(contentsOf: viewModels)

                // Update loading state only after the presented comments are updated
                self._serverCommentsLoadingState.onNext(.notLoading)
            })
            .disposed(by: disposeBag)

        conversationFetchedObservable
            .bind(to: compactCommentVM.inputs.conversationFetched)
            .disposed(by: disposeBag)

        shouldShowErrorLoadingComments
            .bind(to: compactCommentVM.inputs.conversationError)
            .disposed(by: disposeBag)

        // Responding to error states try again tap
        errorStateViewModel.outputs.tryAgainTapped
            .bind(to: tryAgainAfterError)
            .disposed(by: disposeBag)

        compactCommentVM.outputs.tryAgainTapped
            .map { .loadConversationComments }
            .bind(to: tryAgainAfterError)
            .disposed(by: disposeBag)

        // Refresh conversation after login
        loginPromptViewModel
            .outputs
            .authenticationTriggered
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().waitForAuthentication(for: .loginPrompt)
            }
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.servicesProvider.conversationUpdaterService()
                    .update(.refreshConversation, postId: self.postId)
            })
            .disposed(by: disposeBag)

        // First conversation load
        conversationFetchedObservable
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                // Send analytics event
                self.sendEvent(for: .preConversationLoaded)
            })
            .disposed(by: disposeBag)

        // Binding to community question component
        conversationFetchedObservable
            .bind(to: communityQuestionViewModel.inputs.conversationFetched)
            .disposed(by: disposeBag)

        // Set isEmpty
        conversationFetchedObservable
            .subscribe(onNext: { [weak self] conversation in
                guard let self = self else { return }
                if let messageCount = conversation.conversation?.messagesCount, messageCount > 0 {
                    self.isEmpty.onNext(false)
                } else {
                    self.isEmpty.onNext(true)
                }
            })
            .disposed(by: disposeBag)

        // Set read only mode
        conversationFetchedObservable
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                var isReadOnly: Bool = response.conversation?.readOnly ?? false
                switch self.preConversationData.article.additionalSettings.readOnlyMode {
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

        // Re-enabling animations in the pre conversation table view
        conversationFetchedObservable
            .delay(.milliseconds(Metrics.delayBeforeReEnablingTableViewAnimation), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dataSourceTransition = .animated
            })
            .disposed(by: disposeBag)

        isReadOnlyObservable
            .bind(to: compactCommentVM.inputs.isReadOnly)
            .disposed(by: disposeBag)

        isReadOnlyObservable
            .bind(to: commentingCTAViewModel.inputs.isReadOnly)
            .disposed(by: disposeBag)

        commentingCTAViewModel
            .outputs
            .commentCreationTapped
            .do(onNext: { [weak self] in
                self?.sendEvent(for: .createCommentCTAClicked)
            })
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.commentCreationTap.onNext(.comment)
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
                    .share()

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
                guard let self = self else { return }
                self.sendEvent(for: .replyClicked(replyToCommentId: comment.id ?? ""))
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
                guard let self = self else { return }
                self.sendEvent(for: .commentShareClicked(commentId: commentVm.outputs.comment.id ?? ""))
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

        let commentOpenProfileObservable: Observable<OWOpenProfileType> = commentCellsVmsObservable
            .flatMap { commentCellsVms -> Observable<OWOpenProfileType> in
                let avatarClickOutputObservable: [Observable<OWOpenProfileType>] = commentCellsVms.map { commentCellVm in
                    let avatarVM = commentCellVm.outputs.commentVM.outputs.commentHeaderVM.outputs.avatarVM
                    let commentHeaderVM = commentCellVm.outputs.commentVM.outputs.commentHeaderVM
                    return Observable.merge(avatarVM.outputs.openProfile, commentHeaderVM.outputs.openProfile)
                }
                return Observable.merge(avatarClickOutputObservable)
            }

        // Responding to comment avatar and user name tapped
        commentOpenProfileObservable
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

        commentingCTAViewModel.outputs.openProfile
            .do(onNext: { [weak self] _ in
                self?.sendEvent(for: .myProfileClicked(source: .commentCTA))
            })
            .bind(to: _openProfile)
            .disposed(by: disposeBag)

        commentingCTAViewModel
            .outputs
            .authenticationTriggered
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().waitForAuthentication(for: .viewingSelfProfile)
            }
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.servicesProvider.conversationUpdaterService()
                    .update(.refreshConversation, postId: self.postId)
            })
            .disposed(by: disposeBag)

        // Update comments cells on ReadOnly mode
        Observable.combineLatest(commentCellsVmsObservable, isReadOnlyObservable) { commentCellsVms, isReadOnly -> ([OWCommentCellViewModeling], Bool) in
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

        self.servicesProvider.conversationUpdaterService()
            .getConversationUpdates(for: postId)
            .withLatestFrom(commentCellsVmsObservable) { ($0, $1) }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] updateType, commentCellsVms in
                guard let self = self else { return }
                switch updateType {
                case .insert(let comments), .insertRealtime(let comments):
                    let commentsVms: [OWCommentCellViewModel] = comments.map { comment -> OWCommentCellViewModel? in
                        guard let userId = comment.userId,
                              let user = self.servicesProvider.usersService().get(userId: userId)
                        else { return nil }
                        return OWCommentCellViewModel(data: OWCommentRequiredData(
                            comment: comment,
                            user: user,
                            replyToUser: nil,
                            collapsableTextLineLimit: self.preConversationStyle.collapsableTextLineLimit,
                            section: self.preConversationData.article.additionalSettings.section),
                                                      spacing: self.preConversationStyle.spacing.betweenComments)
                    }.unwrap()
                    let viewModels = self._cellsViewModels
                    let filteredCommentsVms = commentsVms.filter { commentVm in
                        // making sure we are not adding an existing comment
                        !commentCellsVms.contains(where: { $0.outputs.commentVM.outputs.comment.id == commentVm.commentVM.outputs.comment.id })
                    }
                    guard !filteredCommentsVms.isEmpty else { return }
                    let preConversationOptions = filteredCommentsVms.map { OWPreConversationCellOption.comment(viewModel: $0) }
                    viewModels.insert(contentsOf: preConversationOptions, at: 0)
                    let numOfComments = self.preConversationStyle.numberOfComments
                    self._cellsViewModels.replaceAll(with: Array(viewModels.prefix(numOfComments)))
                    self.isEmpty.onNext(preConversationOptions.count == 0)
                case let .update(commentId, withComment):
                    self._updateLocalComment.onNext((withComment, commentId))
                case .insertReply:
                    // We are not showing replies in pre conversation
                    break
                case .refreshConversation:
                    self.dataSourceTransition = .reload
                    self._forceRefresh.onNext()
                    self.filterTabsVM.inputs.reloadTabs.onNext()
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
                if let commentCellVm = commentCellsVms.first(where: { $0.outputs.commentVM.outputs.comment.id == commentId }) {
                    commentCellVm.outputs.commentVM.inputs.update(comment: comment)
                    self?._performTableViewAnimation.onNext()
                }
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

        // Open menu for comment and handle actions
        commentCellsVmsObservable
            .flatMapLatest { commentCellsVms -> Observable<([OWRxPresenterAction], OWUISource, OWCommentViewModeling)> in
                let openMenuClickObservable = commentCellsVms.map { commentCellVm -> Observable<([OWRxPresenterAction], OWUISource, OWCommentViewModeling)> in
                    let commentVm = commentCellVm.outputs.commentVM

                    return commentVm.outputs.commentOptionsVM.outputs.openMenu
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
            .flatMapLatest { commentCellsVms -> Observable<OWClarityDetailsRequireData> in
                let learnMoreClickObservable: [Observable<OWClarityDetailsRequireData>] = commentCellsVms.map { commentCellVm -> Observable<OWClarityDetailsRequireData> in
                    let commentStatusVm = commentCellVm.outputs.commentVM.outputs.commentStatusVM
                    return commentStatusVm.outputs.learnMoreClicked
                        .map { OWClarityDetailsRequireData(commentId: commentCellVm.outputs.id, type: $0) }
                }
                return Observable.merge(learnMoreClickObservable)
            }
            .subscribe(onNext: { [weak self] clarityDetailsData in
                self?.openClarityDetailsChange.onNext(clarityDetailsData)
                // send analytics for rejected
                if clarityDetailsData.type == .rejected {
                    self?.sendEvent(for: .rejectedNoticeLearnMoreClicked(commentId: clarityDetailsData.commentId))
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
        let userTryingToChangeRankObservable = commentCellsVmsObservable
            // 1. Observe comments rank clicked
            .flatMap { commentCellsVms -> Observable<(OWCommentViewModeling, SPRankChange)> in
                let rankClickObservable: [Observable<(OWCommentViewModeling, SPRankChange)>] = commentCellsVms.map { commentCellVm -> Observable<(OWCommentViewModeling, SPRankChange)> in
                    let commentVm = commentCellVm.outputs.commentVM
                    let commentRankVm = commentVm.outputs.commentEngagementVM.outputs.votingVM

                    return commentRankVm.outputs.rankChangeTriggered
                        .map { (commentVm, $0) }
                }
                return Observable.merge(rankClickObservable)
            }
            .flatMapLatest { [weak self] commentVm, rankChange -> Observable<(OWCommentViewModeling, SPRankChange, Bool)> in
                // 2. Triggering authentication UI if needed
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().ifNeededTriggerAuthenticationUI(for: .votingComment)
                    .map { (commentVm, rankChange, $0) }
            }
            .flatMapLatest { [weak self] commentVm, rankChange, neededToAuthenticate -> Observable<(OWCommentViewModeling, SPRankChange, Bool)?> in
                // 3. Waiting for authentication required for voting
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().waitForAuthentication(for: .votingComment)
                    .map { $0 ? (commentVm, rankChange, neededToAuthenticate) : nil }
            }
            .unwrap()

        userTryingToChangeRankObservable
            .do(onNext: { [weak self] commentVm, rankChange, _ in
                // 4. Send rank changed analytics event
                guard let self = self,
                      let commentId = commentVm.outputs.comment.id,
                      let eventType = rankChange.analyticsEventType(commentId: commentId)
                else { return }
                self.sendEvent(for: eventType)
            })
            .subscribe(onNext: { [weak self] commentVm, rankChange, userLoggedIn in
                // 5. Handle rank change
                guard let self = self,
                      let commentId = commentVm.outputs.comment.id
                else { return }
                if userLoggedIn {
                    self.servicesProvider.conversationUpdaterService().update(.refreshConversation, postId: self.postId)
                    self._openCommentThread.onNext((commentId, .changeRank(from: rankChange.from.rawValue,
                                                                           to: rankChange.to.rawValue)))
                } else {
                    let commentRankVm = commentVm.outputs.commentEngagementVM.outputs.votingVM
                    commentRankVm.inputs.rankChanged.onNext(rankChange)
                }
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
                switch result {
                case .completion:
                    return false
                case .selected(let action):
                    switch action.type {
                    case OWCommentDeleteAlert.delete:
                        self?.sendEvent(for: .commentMenuConfirmDeleteClicked(commentId: commentVm.outputs.comment.id ?? ""))
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
                    .networkAPI()
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
                        .delay(.milliseconds(Metrics.delayAfterRecievingUpdatedComments), scheduler: self.preConversationViewVMScheduler)
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

        // Handling mute user from network
        muteUserObservable
            .flatMap { [weak self] userId -> Observable<Event<OWNetworkEmpty>> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                    .networkAPI()
                    .user
                    .mute(userId: userId)
                    .response
                    .materialize()
            }
            .map { [weak self] event -> Bool in
                guard let self = self else { return false }
                switch event {
                case .next:
                    // TODO: Clear any RX variables which affect error state in the View layer (like _shouldShowError).
                    let data = OWToastRequiredData(type: .success, action: .none, title: OWLocalizationManager.shared.localizedString(key: "MuteSuccessToast"))
                    self.servicesProvider.toastNotificationService()
                        .showToast(data: OWToastNotificationCombinedData(presentData: OWToastNotificationPresentData(data: data),
                                                                         actionCompletion: nil))
                    return true
                case .error(_):
                    // TODO: handle error - update something like _shouldShowError RX variable which affect the UI state for showing error in the View layer
                    let data = OWToastRequiredData(type: .warning, action: .tryAgain, title: OWLocalizationManager.shared.localizedString(key: "SomethingWentWrong"))
                    self.servicesProvider.toastNotificationService()
                        .showToast(data: OWToastNotificationCombinedData(presentData: OWToastNotificationPresentData(data: data),
                                                                         actionCompletion: self.retryMute))
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

        // Retry when triggerd
        retryMute
            .withLatestFrom(muteCommentUser) { _, comment -> OWCommentViewModeling in
                return comment
            }
            .subscribe(onNext: { [weak self] comment in
                self?.muteCommentUser.onNext(comment)
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

        fullConversationCTATap
            .asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.sendEvent(for: .showMoreComments)
            })
            .disposed(by: disposeBag)

        servicesProvider
            .activeArticleService()
            .articleExtraData
            .subscribe(onNext: { [weak self] article in
                self?.articleUrl = article.url.absoluteString
            })
            .disposed(by: disposeBag)

        // Send analytics for community guidelines click
        communityGuidelinesViewModel.outputs.urlClickedOutput
            .subscribe(onNext: { [weak self] _ in
                self?.sendEvent(for: .communityGuidelinesLinkClicked)
            })
            .disposed(by: disposeBag)

        tableViewSizeChanged
            .subscribe(onNext: { [weak self] size in
                guard let self = self else { return }
                self.servicesProvider
                    .conversationSizeService()
                    .setConversationTableSize(size)
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

        commentThreadActionsCellsVmsObservable
            .flatMapLatest { commentThreadActionsCellsVms -> Observable<(OWCommentPresentationData, OWCommentThreadActionsCellMode, BehaviorSubject<Bool>)> in
                let threadActionsClickObservable = commentThreadActionsCellsVms.map { commentThreadActionsCellsVm in
                    return commentThreadActionsCellsVm.outputs.commentActionsVM
                        .outputs.tapOutput
                        .map { (commentThreadActionsCellsVm.outputs.commentPresentationData,
                                commentThreadActionsCellsVm.outputs.mode,
                                commentThreadActionsCellsVm.outputs.commentActionsVM.inputs.isLoading) }
                }

                return Observable.merge(threadActionsClickObservable)
            }
            .subscribe(onNext: { [weak self] commentPresentationData, mode, isLoading in
                guard let self = self else { return }
                switch mode {
                case .openCommentThread:
                    self._openCommentThread.onNext((commentPresentationData.id, .none))
                    isLoading.onNext(false)
                default:
                    // not relevant
                    break
                }
            })
            .disposed(by: disposeBag)

        // Actions after internet connection restored
        servicesProvider
            .networkAvailabilityService()
            .networkAvailable
            .scan((false, nil), accumulator: { previous, current -> (Bool, Bool?) in
                // first time no need to update
                guard let previousValue = previous.1 else {
                    return (false, current)
                }
                // Need to update only if internet is restored
                if previousValue == false && current == true {
                    return (true, current)
                } else {
                    return (false, current)
                }
            })
            .filter { $0.0 } // Continue only if result is true
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                // Trigger re-fetching config
                self.communityGuidelinesViewModel.inputs.retryGetConfig.onNext(())
                // Trigger re-fetching conversation
                self.tryAgainAfterError.onNext(.loadConversationComments)
            })
            .disposed(by: disposeBag)

        dismissToast
            .bind(to: servicesProvider.toastNotificationService().clearCurrentToast)
            .disposed(by: disposeBag)
    }
    // swiftlint:enable function_body_length

    func isNonTableViewStyle(_ style: OWPreConversationStyle) -> Bool {
        switch style {
        case .compact, .ctaButtonOnly, .ctaWithSummary:
            return true
        default:
            return false
        }
    }

    func populateInitialUI() {
        if !self.isCompactMode {
            let numberOfComments = self.preConversationStyle.numberOfComments
            let skeletonCellVMs = (0 ..< numberOfComments).map { _ in OWCommentSkeletonShimmeringCellViewModel() }
            let skeletonCells = skeletonCellVMs.map { OWPreConversationCellOption.commentSkeletonShimmering(viewModel: $0) }
            _cellsViewModels.append(contentsOf: skeletonCells)
        }
    }

    func event(for eventType: OWAnalyticEventType) -> OWAnalyticEvent {
        return servicesProvider
            .analyticsEventCreatorService()
            .analyticEvent(
                for: eventType,
                articleUrl: articleUrl,
                layoutStyle: OWLayoutStyle(from: preConversationData.presentationalMode),
                component: .preConversation)
    }

    func sendEvent(for eventType: OWAnalyticEventType) {
        let event = event(for: eventType)
        servicesProvider
            .analyticsService()
            .sendAnalyticEvents(events: [event])
    }
}
