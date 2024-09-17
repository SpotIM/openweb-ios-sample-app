//
//  OWConversationCoordinator.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 05/07/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

enum OWConversationCoordinatorResult: OWCoordinatorResultProtocol {
    case popped
    case loadedToScreen

    var loadedToScreen: Bool {
        switch self {
        case .loadedToScreen:
            return true
        default:
            return false
        }
    }
}

class OWConversationCoordinator: OWBaseCoordinator<OWConversationCoordinatorResult> {
    // Router is being used only for `Flows` mode. Intentionally defined as force unwrap for easy access.
    // Trying to use that in `Standalone Views` mode will cause a crash immediately.
    fileprivate let router: OWRoutering!
    fileprivate let conversationData: OWConversationRequiredData
    fileprivate let viewActionsCallbacks: OWViewActionsCallbacks?
    fileprivate let flowActionsCallbacks: OWFlowActionsCallbacks?
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate var viewableMode: OWViewableMode!
    fileprivate lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: viewActionsCallbacks, viewSourceType: .conversation)
    }()
    fileprivate lazy var flowActionsService: OWFlowActionsServicing = {
        return OWFlowActionsService(flowActionsCallbacks: flowActionsCallbacks, viewSourceType: .conversation)
    }()
    fileprivate lazy var customizationsService: OWCustomizationsServicing = {
        return OWCustomizationsService(viewSourceType: .conversation)
    }()

    fileprivate var _openCommentThread = PublishSubject<(OWCommentId, OWCommentThreadPerformActionType)>()

    fileprivate struct Metrics {
        static let delayCommentThreadAfterReport: CGFloat = 0.5
    }

    fileprivate let conversationPopped = PublishSubject<Void>()

    init(router: OWRoutering! = nil,
         conversationData: OWConversationRequiredData,
         viewActionsCallbacks: OWViewActionsCallbacks?,
         flowActionsCallbacks: OWFlowActionsCallbacks?,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.router = router
        self.conversationData = conversationData
        self.viewActionsCallbacks = viewActionsCallbacks
        self.flowActionsCallbacks = flowActionsCallbacks
        self.servicesProvider = servicesProvider
    }

    // swiftlint:disable function_body_length
    override func start(coordinatorData: OWCoordinatorData? = nil) -> Observable<OWConversationCoordinatorResult> {
        viewableMode = .partOfFlow
        let conversationVM: OWConversationViewModeling = OWConversationViewModel(conversationData: conversationData,
                                                                                 viewableMode: viewableMode)
        let conversationVC = OWConversationVC(viewModel: conversationVM)

        setupObservers(forViewModel: conversationVM)
        setupFlowActionsCallbacks(forViewModel: conversationVM)

        let deepLinkToCommentCreation = BehaviorSubject<OWCoordinatorData?>(value: nil)
        let deepLinkToCommentThread = BehaviorSubject<OWCommentThreadRequiredData?>(value: nil)
        let deepLinkToReportReason = BehaviorSubject<OWReportReasonsRequiredData?>(value: nil)
        let deepLinkToClarityDetails = BehaviorSubject<OWClarityDetailsRequireData?>(value: nil)

        var animated = true

        // Support deep links which related to conversation
        if let deepLink = coordinatorData?.deepLink {
            switch deepLink {
            case .commentCreation(let commentCreationData):
                switch commentCreationData.settings.commentCreationSettings.style {
                case .regular, .light:
                    animated = false
                case .floatingKeyboard:
                    animated = true
                }
                deepLinkToCommentCreation.onNext(coordinatorData)
            case .commentThread(let commentThreadData):
                animated = false
                deepLinkToCommentThread.onNext(commentThreadData)
            case .highlightComment(let commentId):
                conversationVM.inputs.highlightComment.onNext(commentId)
            case .reportReason(let reportData):
                animated = false
                deepLinkToReportReason.onNext(reportData)
            case .clarityDetails(let data):
                animated = false
                deepLinkToClarityDetails.onNext(data)
            default:
                break
            }
        }

        // Conversation is the initial view in the router so here we start the router
        router.start()

        if router.isEmpty() {
            router.setRoot(conversationVC, animated: false, dismissCompletion: conversationPopped)
        } else {
            router.push(conversationVC,
                        pushStyle: .regular,
                        animated: animated,
                        popCompletion: conversationPopped)
        }

        // CTA, Reply or Edit tapped from conversation screen
        let openCommentCreationObservable = conversationVM.outputs.conversationViewVM.outputs.openCommentCreation
            .observe(on: MainScheduler.instance)
            .map { [weak self] type -> OWCoordinatorData? in
                // Here we are generating `OWCommentCreationRequiredData` and new fields in this struct will have default values
                guard let self = self else { return nil }
                let commentCreationData = OWCommentCreationRequiredData(article: self.conversationData.article,
                                                     settings: self.conversationData.settings,
                                                     commentCreationType: type,
                                                     presentationalStyle: self.conversationData.presentationalMode)
                return OWCoordinatorData(deepLink: .commentCreation(commentCreationData: commentCreationData),
                                         source: .conversation)
            }
            .unwrap()

        // Coordinate to comment creation
        // TODO - handle read only mode
        let coordinateCommentCreationObservable = Observable.merge(
            openCommentCreationObservable,
            deepLinkToCommentCreation.unwrap().asObservable())

            .filter { [weak self] _ in
                guard let self = self else { return false }
                return self.viewableMode == .partOfFlow
            }
            .flatMapLatest { [weak self] coordinatorData -> Observable<OWCommentCreationCoordinatorResult> in
                guard let self = self else { return .empty() }
                switch coordinatorData.deepLink {
                    case .commentCreation(let commentCreationData):
                        let commentCreationCoordinator = OWCommentCreationCoordinator(router: self.router,
                                                                                      commentCreationData: commentCreationData,
                                                                                      viewActionsCallbacks: self.viewActionsCallbacks)
                        return self.coordinate(to: commentCreationCoordinator, coordinatorData: coordinatorData)
                    default:
                        return .empty()
                }
            }
            .do(onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .commentCreated:
                    break
                case let .userLoggedInWhileWritingReplyToComment(commentId):
                    self._openCommentThread.onNext((commentId, .reply))
                case .loadedToScreen:
                    break
                    // Nothing
                case .popped:
                    break
                }
            })
            .flatMapLatest { _ -> Observable<OWConversationCoordinatorResult> in
                return Observable.never()
            }

        let reportReasonFromConversationObservable = conversationVM.outputs.conversationViewVM
            .outputs.openReportReason
            .map { commentVM -> OWReportReasonsRequiredData? in
                guard let commentId = commentVM.outputs.comment.id,
                    let parentId = commentVM.outputs.comment.parentId else {
                    return nil
                }

                return OWReportReasonsRequiredData(commentId: commentId, parentId: parentId)
            }
            .unwrap()

        // Coordinate to report reason
        let coordinateReportReasonObservable = Observable.merge(deepLinkToReportReason.unwrap(), reportReasonFromConversationObservable)
            .asObservable()
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return self.viewableMode == .partOfFlow
            }
            .flatMap { [weak self] reportData -> Observable<OWReportReasonCoordinatorResult> in
                guard let self = self else { return .empty() }
                let reportReasonCoordinator = OWReportReasonCoordinator(reportData: reportData,
                                                                        router: self.router,
                                                                        viewActionsCallbacks: self.viewActionsCallbacks,
                                                                        presentationalMode: self.conversationData.presentationalMode)
                return self.coordinate(to: reportReasonCoordinator)
            }
            .do(onNext: { [weak self] coordinatorResult in
                switch coordinatorResult {
                case .popped:
                    // Nothing
                    break
                case let .submitedReport(commentId, userJustLoggedIn):
                    guard userJustLoggedIn else { return }

                    // Delay open Comment Thread so that the
                    // report reason flow closes first
                    DispatchQueue.main.asyncAfter(deadline: .now() + Metrics.delayCommentThreadAfterReport) {
                        self?._openCommentThread.onNext((commentId, .report))
                    }
                default:
                    break
                }
            })
            .flatMap { _ -> Observable<OWConversationCoordinatorResult> in
                return Observable.never()
            }

        let clarityDetailsFromConversationObservable = conversationVM.outputs.conversationViewVM.outputs.openClarityDetails

        // Coordinate to clarity details
        let coordinateClarityDetailsObservable = Observable.merge(
            deepLinkToClarityDetails.unwrap(),
            clarityDetailsFromConversationObservable)
            .asObservable()
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return self.viewableMode == .partOfFlow
            }
            .flatMap { [weak self] data -> Observable<OWClarityDetailsCoordinatorResult> in
                guard let self = self else { return .empty() }
                let clarityDetailsCoordinator = OWClarityDetailsCoordinator(data: data,
                                                                            router: self.router,
                                                                            viewActionsCallbacks: self.viewActionsCallbacks)
                return self.coordinate(to: clarityDetailsCoordinator)
            }
            .do(onNext: { coordinatorResult in
                switch coordinatorResult {
                case .popped:
                    // Nothing
                    break
                default:
                    break
                }
            })
            .flatMap { _ -> Observable<OWConversationCoordinatorResult> in
                return Observable.never()
            }

        let openCommentThreadObservable = Observable.merge(conversationVM.outputs.conversationViewVM.outputs.openCommentThread, _openCommentThread)
            .observe(on: MainScheduler.instance)
            .map { [weak self] commentId, performAction -> OWCommentThreadRequiredData? in
                guard let self = self else { return nil }

                guard var newAdditionalSettings = self.conversationData.settings as? OWAdditionalSettings,
                      var newCommentThreadSettings = newAdditionalSettings.commentThreadSettings as? OWCommentThreadSettings
                else { return nil }

                newCommentThreadSettings.performActionType = performAction
                newAdditionalSettings.commentThreadSettings = newCommentThreadSettings

                return OWCommentThreadRequiredData(article: self.conversationData.article,
                                                   settings: newAdditionalSettings,
                                                   commentId: commentId,
                                                   presentationalMode: self.conversationData.presentationalMode)
            }
            .unwrap()

        // Coordinate to comment thread
        let coordinateCommentThreadObservable = Observable.merge(deepLinkToCommentThread.unwrap().asObservable(),
                                                                 openCommentThreadObservable)
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return self.viewableMode == .partOfFlow
            }
            .flatMap { [weak self] commentThreadData -> Observable<OWCommentThreadCoordinatorResult> in
                guard let self = self else { return .empty() }
                let commentThreadCoordinator = OWCommentThreadCoordinator(router: self.router,
                                                                          commentThreadData: commentThreadData,
                                                                          viewActionsCallbacks: self.viewActionsCallbacks,
                                                                          flowActionsCallbacks: self.flowActionsCallbacks)
                return self.coordinate(to: commentThreadCoordinator)
            }
            .do(onNext: { result in
                switch result {
                case .loadedToScreen:
                    break
                    // Nothing
                case .popped:
                    break
                }
            })
            .flatMap { _ -> Observable<OWConversationCoordinatorResult> in
                return Observable.never()
            }

        // URL tapped from community guidelines screen
        let communityGuidelinesURLTapped = conversationVM.outputs
            .conversationViewVM.outputs
            .communityGuidelinesCellViewModel.outputs
            .communityGuidelinesViewModel.outputs
            .urlClickedOutput

        // Coordinate to safari tab
        let profilePageTitle = OWLocalizationManager.shared.localizedString(key: "ProfileTitle")
        let coordinateToSafariObservables = Observable.merge(
            communityGuidelinesURLTapped.map { ($0, "") },
            conversationVM.outputs.conversationViewVM.outputs.commentingCTAViewModel.outputs.openProfile.map {
                if case .OWProfile(let data) = $0 {
                    return (data.url, profilePageTitle)
                } else {
                    return nil
                }
            }.unwrap(),
            conversationVM.outputs.conversationViewVM.outputs.urlClickedOutput.map { ($0, "") },
            conversationVM.outputs.conversationViewVM.outputs.openProfile.map {
                if case .OWProfile(let data) = $0 {
                    return (data.url, profilePageTitle)
                } else {
                    return nil
                }
            }.unwrap()
        )

        let coordinateToSafariObservable = coordinateToSafariObservables
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return self.viewableMode == .partOfFlow
            }
            .flatMap { [weak self] tuple -> Observable<OWWebTabCoordinatorResult> in
                guard let self = self else { return .empty() }
                let url = tuple.0
                let title = tuple.1
                let options = OWWebTabOptions(url: url,
                                                 title: title)
                let safariCoordinator = OWWebTabCoordinator(router: self.router,
                                                            options: options,
                                                            viewActionsCallbacks: self.viewActionsCallbacks)
                return self.coordinate(to: safariCoordinator, coordinatorData: nil)
            }
            .do(onNext: { result in
                switch result {
                case .loadedToScreen:
                    break
                    // Nothing
                case .popped:
                    break
                }
            })
            .flatMap { _ -> Observable<OWConversationCoordinatorResult> in
                return Observable.never()
            }

        let indipendentConversationClosedObservable = conversationVM.outputs
            .conversationViewVM.outputs
            .conversationTitleHeaderViewModel.outputs
            .closeConversation

        let partOfFlowPresentedConversationClosedObservable = conversationVM.outputs.closeConversation

        let conversationPoppedObservable = Observable.merge(conversationPopped,
                                                            indipendentConversationClosedObservable,
                                                            partOfFlowPresentedConversationClosedObservable)
            .do(onNext: { [weak self] in
                guard let self = self,
                      let postId = OWManager.manager.postId
                else { return }
                self.servicesProvider.lastCommentTypeInMemoryCacheService().remove(forKey: postId)
            })
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                guard self.viewableMode == .partOfFlow else {
                    return Observable.just(())
                }
                return flowActionsService.serviceQueueEmpty
            }
            .map { OWConversationCoordinatorResult.popped }
            .asObservable()

        let conversationLoadedObservable = conversationVM.outputs.loadedToScreen
            .map { OWConversationCoordinatorResult.loadedToScreen }
            .asObservable()

        return Observable.merge(
            conversationPoppedObservable,
            coordinateCommentCreationObservable,
            coordinateReportReasonObservable,
            coordinateClarityDetailsObservable,
            coordinateCommentThreadObservable,
            conversationLoadedObservable,
            coordinateToSafariObservable
        )
    }
    // swiftlint:enable function_body_length

    override func showableComponent() -> Observable<OWShowable> {
        viewableMode = .independent
        let conversationViewVM: OWConversationViewViewModeling = OWConversationViewViewModel(conversationData: conversationData,
                                                                                             viewableMode: viewableMode)
        let conversationView = OWConversationView(viewModel: conversationViewVM)
        setupObservers(forViewModel: conversationViewVM)
        setupViewActionsCallbacks(forViewModel: conversationViewVM)
        return .just(conversationView)
    }
}

fileprivate extension OWConversationCoordinator {
    func setupObservers(forViewModel viewModel: OWConversationViewModeling) {
        setupObservers(forViewModel: viewModel.outputs.conversationViewVM)

        setupCustomizationElements(forViewModel: viewModel)
    }

    func setupFlowActionsCallbacks(forViewModel viewModel: OWConversationViewModeling) {
        guard flowActionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided

        let conversationDismissed = conversationPopped
            .map { OWFlowActionCallbackType.conversationDismissed }

        let closeConversationPressed = viewModel
            .outputs.closeConversation
            .map { OWFlowActionCallbackType.conversationDismissed }

        let openPublisherProfile = Observable.merge(
            viewModel.outputs.conversationViewVM.outputs.openProfile,
            viewModel.outputs.conversationViewVM.outputs.commentingCTAViewModel.outputs.openProfile
        )
            .map { [weak self] openProfileType -> OWFlowActionCallbackType? in
                guard let self = self else { return nil }
                switch(openProfileType) {
                case .publisherProfile(let ssoPublisherId, let type):
                    let presentationMode = self.conversationData.presentationalMode.presentationalMode
                    return OWFlowActionCallbackType.openPublisherProfile(ssoPublisherId: ssoPublisherId,
                                                                         type: type,
                                                                         presentationalMode: presentationMode)
                default:
                    return nil
                }
            }
            .unwrap()
            .asObservable()

        Observable.merge(
            conversationDismissed,
            closeConversationPressed,
            openPublisherProfile)
            .subscribe { [weak self] flowActionType in
                self?.flowActionsService.append(flowAction: flowActionType)
            }
            .disposed(by: disposeBag)
    }

    func setupObservers(forViewModel viewModel: OWConversationViewViewModeling) {
        // TODO: Setting up general observers which affect app flow however not entirely inside the SDK

        setupCustomizationElements(forViewModel: viewModel)
    }

    func setupViewActionsCallbacks(forViewModel viewModel: OWConversationViewViewModeling) {
        guard viewActionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided

        let actionsCallbacksNotifier = self.servicesProvider.actionsCallbacksNotifier()

        let closeConversationPressed = viewModel
            .outputs.conversationTitleHeaderViewModel
            .outputs.closeConversation
            .map { OWViewActionCallbackType.closeConversationPressed }

        let openPublisherProfile = Observable.merge(
            viewModel.outputs.openProfile,
            viewModel.outputs.commentingCTAViewModel.outputs.openProfile
        )
            .map { openProfileType in
                switch(openProfileType) {
                case .OWProfile(let data):
                    return OWViewActionCallbackType.openOWProfile(data: data)
                case .publisherProfile(let ssoPublisherId, let type):
                    return OWViewActionCallbackType.openPublisherProfile(ssoPublisherId: ssoPublisherId, type: type)
                }
            }

        let openReportReason = viewModel.outputs.openReportReason
            .map { commentVM -> OWViewActionCallbackType in
                guard let commentId = commentVM.outputs.comment.id,
                      let parentId = commentVM.outputs.comment.parentId else { return .error(.reportReasonFlow) }
                return OWViewActionCallbackType.openReportReason(commentId: commentId, parentId: parentId)
            }

        let communityGuidelinesURLTapped = viewModel.outputs
            .communityGuidelinesCellViewModel.outputs
            .communityGuidelinesViewModel.outputs
            .urlClickedOutput
        let openCommunityGuidelines = communityGuidelinesURLTapped
            .map { OWViewActionCallbackType.communityGuidelinesPressed(url: $0) }

        // Open comment creation
        let openCommentCreation = viewModel.outputs.openCommentCreation
            .map { internalType -> OWCommentCreationType in
                switch internalType {
                case .comment:
                    return OWCommentCreationType.comment
                case .replyToComment(let originComment):
                    return .replyTo(commentId: originComment.id ?? "")
                case .edit(let comment):
                    return .edit(commentId: comment.id ?? "")
                }
            }
            .map { OWViewActionCallbackType.openCommentCreation(type: $0) }

        // Open clarity details
        let openClarityDetails = viewModel.outputs.openClarityDetails
            .map { OWViewActionCallbackType.openClarityDetails(data: $0) }

        // Open URL in comment
        let openUrlInComment = viewModel.outputs.urlClickedOutput
            .map { OWViewActionCallbackType.openLinkInComment(url: $0) }

        let openCommentThread = Observable.merge(viewModel.outputs.openCommentThread, actionsCallbacksNotifier.openCommentThread)
            .map { OWViewActionCallbackType.openCommentThread(commentId: $0, performActionType: $1) }

        Observable.merge(
            closeConversationPressed,
            openPublisherProfile,
            openReportReason,
            openCommunityGuidelines,
            openCommentCreation,
            openClarityDetails,
            openUrlInComment,
            openCommentThread)
            .subscribe { [weak self] viewActionType in
                self?.viewActionsService.append(viewAction: viewActionType)
            }
            .disposed(by: disposeBag)
    }

    func setupCustomizationElements(forViewModel viewModel: OWConversationViewModeling) {
        let customizeNavigationItem = viewModel.outputs.customizeNavigationItemUI
            .map { OWCustomizableElement.navigation(element: .navigationItem($0)) }

        let customizeNavigationBar = viewModel.outputs.customizeNavigationBarUI
            .map { OWCustomizableElement.navigation(element: .navigationBar($0)) }

        let customizationElementsObservables = Observable.merge(customizeNavigationItem,
                                                                customizeNavigationBar)

        customizationElementsObservables
            .subscribe { [weak self] element in
                self?.customizationsService.trigger(customizableElement: element)
            }
            .disposed(by: disposeBag)
    }

    // swiftlint:disable function_body_length
    func setupCustomizationElements(forViewModel viewModel: OWConversationViewViewModeling) {
        // swiftlint:enable function_body_length

        // Set customized title header
        let conversationTitleHeaderCustomizeTitle = viewModel.outputs.conversationTitleHeaderViewModel
            .outputs.customizeTitleLabelUI
            .map { OWCustomizableElement.header(element: .title(label: $0)) }

        let conversationTitleHeaderCustomizeCloseButton = viewModel.outputs.conversationTitleHeaderViewModel
            .outputs.customizeCloseButtonUI
            .map { OWCustomizableElement.header(element: .close(button: $0)) }

        let conversationTitleHeaderCustomizationElementsObservable = Observable.merge(conversationTitleHeaderCustomizeTitle,
                                                                                      conversationTitleHeaderCustomizeCloseButton)

        // Set customized article header
        let articelDescriptionCustomizeTitle = viewModel.outputs.articleDescriptionViewModel
            .outputs.customizeTitleLabelUI
            .map { OWCustomizableElement.articleDescription(element: .title(label: $0)) }

        let articelDescriptionCustomizeAuthor = viewModel.outputs.articleDescriptionViewModel
            .outputs.customizeAuthorLabelUI
            .map { OWCustomizableElement.articleDescription(element: .author(label: $0)) }

        let articelDescriptionCustomizeImage = viewModel.outputs.articleDescriptionViewModel
            .outputs.customizeImageViewUI
            .map { OWCustomizableElement.articleDescription(element: .image(imageView: $0)) }

        let articleDescriptionCustomizationElementsObservable = Observable.merge(articelDescriptionCustomizeTitle,
                                                                                 articelDescriptionCustomizeAuthor,
                                                                                 articelDescriptionCustomizeImage)

        // Set customized login prompt
        let loginPromptCustomizeLockImage = viewModel.outputs.loginPromptViewModel
            .outputs.customizeLockIconImageViewUI
            .map { OWCustomizableElement.loginPrompt(element: .lockIcon(imageView: $0)) }

        let loginPromptCustomizeTitle = viewModel.outputs.loginPromptViewModel
            .outputs.customizeTitleLabelUI
            .map { OWCustomizableElement.loginPrompt(element: .title(label: $0)) }

        let loginPromptCustomizeArrowImage = viewModel.outputs.loginPromptViewModel
            .outputs.customizeArrowIconImageViewUI
            .map { OWCustomizableElement.loginPrompt(element: .arrowIcon(imageView: $0)) }

        let loginPromptCustomizationElementsObservable = Observable.merge(loginPromptCustomizeLockImage,
                                                                          loginPromptCustomizeTitle,
                                                                          loginPromptCustomizeArrowImage)

        // Set customized conversation summary
        let summaryCustomizeCounter = viewModel.outputs.conversationSummaryViewModel
            .outputs.customizeCounterLabelUI
            .map { OWCustomizableElement.summary(element: .commentsTitle(label: $0)) }

        let summaryCustomizeOnlineUsersIcon = viewModel.outputs.conversationSummaryViewModel
            .outputs.onlineViewingUsersVM
            .outputs.customizeIconImageUI
            .map { OWCustomizableElement.onlineUsers(element: .icon(image: $0)) }

        let summaryCustomizeOnlineUsersCounter = viewModel.outputs.conversationSummaryViewModel
            .outputs.onlineViewingUsersVM
            .outputs.customizeCounterLabelUI
            .map { OWCustomizableElement.onlineUsers(element: .counter(label: $0)) }

        let summaryCustomizeSortBy = viewModel.outputs.conversationSummaryViewModel
            .outputs.conversationSortVM
            .outputs.customizeSortByLabelUI
            .map { OWCustomizableElement.summary(element: .sortByTitle(label: $0)) }

        let summaryCustomizationElementsObservable = Observable.merge(summaryCustomizeCounter,
                                                                      summaryCustomizeOnlineUsersIcon,
                                                                      summaryCustomizeOnlineUsersCounter,
                                                                      summaryCustomizeSortBy)

        // Set customized community question
        let communityQuestionCustomizeContainer = viewModel.outputs.communityQuestionCellViewModel
            .outputs.communityQuestionViewModel
            .outputs.customizeQuestionContainerViewUI

        let communityQuestionCustomizeTitle = viewModel.outputs.communityQuestionCellViewModel
            .outputs.communityQuestionViewModel
            .outputs.customizeQuestionTitleLabelUI

        let communityQuestionStyle = viewModel.outputs.communityQuestionCellViewModel
            .outputs.communityQuestionViewModel
            .outputs.style

        let communityQuestionCustomizationElementObservable = Observable.combineLatest(communityQuestionCustomizeContainer,
                                                                                    communityQuestionCustomizeTitle)
            .flatMap { container, title in
                switch communityQuestionStyle {
                case .regular:
                    return Observable.just(OWCustomizableElement.communityQuestion(element: .regular(label: title)))
                case .compact:
                    return Observable.just(OWCustomizableElement.communityQuestion(element: .compact(containerView: container, label: title)))
                case .none:
                    return .empty()
                }
            }

        // Set customized community guidelines
        let communityGuidelinesCustomizeContainer = viewModel.outputs.communityGuidelinesCellViewModel
            .outputs.communityGuidelinesViewModel
            .outputs.customizeContainerViewUI

        let communityGuidelinesCustomizeTitle = viewModel.outputs.communityGuidelinesCellViewModel
            .outputs.communityGuidelinesViewModel
            .outputs.customizeTitleLabelUI

        let communityGuidelinesCustomizeIcon = viewModel.outputs.communityGuidelinesCellViewModel
            .outputs.communityGuidelinesViewModel
            .outputs.customizeIconImageViewUI

        let communityGuidelinesStyle = viewModel.outputs.communityGuidelinesCellViewModel
            .outputs.communityGuidelinesViewModel
            .outputs.style

        let communityGuidelinesCustomizationElementObservable = Observable.combineLatest(communityGuidelinesCustomizeContainer,
                                                                                      communityGuidelinesCustomizeIcon,
                                                                                      communityGuidelinesCustomizeTitle)
            .flatMap { container, icon, title in
                switch communityGuidelinesStyle {
                case .regular:
                    return Observable.just(OWCustomizableElement.communityGuidelines(element: .regular(label: title)))
                case .compact:
                    return Observable.just(OWCustomizableElement.communityGuidelines(element: .compact(containerView: container, icon: icon, label: title)))
                case .none:
                    return .empty()
                }
            }

        // Set customized conversation empty state

        let conversationEmptyStateCustomizeIcon = viewModel.outputs.conversationEmptyStateCellViewModel
            .outputs.conversationEmptyStateViewModel
            .outputs.customizeIconImageViewUI

        let conversationEmptyStateCustomizeTitle = viewModel.outputs.conversationEmptyStateCellViewModel
            .outputs.conversationEmptyStateViewModel
            .outputs.customizeTitleLabelUI

        let emptyStateCustomizeIcon = conversationEmptyStateCustomizeIcon
            .map { OWCustomizableElement.emptyState(element: .icon(image: $0)) }

        let emptyStateCustomizeTitle = conversationEmptyStateCustomizeTitle
            .map { OWCustomizableElement.emptyState(element: .title(label: $0)) }

        let emptyStateCommentingEndedCustomizeIcon = conversationEmptyStateCustomizeIcon
            .map { OWCustomizableElement.emptyStateCommentingEnded(element: .icon(imageView: $0)) }

        let emptyStateCommentingEndedCustomizeTitle = conversationEmptyStateCustomizeTitle
            .map { OWCustomizableElement.emptyStateCommentingEnded(element: .title(label: $0)) }

        let conversationEmptyStateCustomizationElementsObservable = Observable.merge(emptyStateCustomizeIcon,
                                                                                     emptyStateCustomizeTitle,
                                                                                     emptyStateCommentingEndedCustomizeIcon,
                                                                                     emptyStateCommentingEndedCustomizeTitle)

        // Commenting CTA

        let commentingCTAViewModel = viewModel.outputs.commentingCTAViewModel

        // Set customized comment creation

        let commentCreationEntryCustomizeContainer = commentingCTAViewModel
            .outputs.commentCreationEntryViewModel
            .outputs.customizeContainerViewUI
            .map { OWCustomizableElement.commentCreationCTA(element: .container(view: $0)) }

        let commentCreationEntryCustomizeTitle = commentingCTAViewModel
            .outputs.commentCreationEntryViewModel
            .outputs.customizeTitleLabelUI
            .map { OWCustomizableElement.commentCreationCTA(element: .placeholder(label: $0)) }

        let commentCreationEntryCustomizationElementsObservable = Observable.merge(commentCreationEntryCustomizeContainer,
                                                                                   commentCreationEntryCustomizeTitle)

        // Set customized commenting read only

        let commentingReadOnlyCustomizeIcon = commentingCTAViewModel
            .outputs.commentingReadOnlyViewModel
            .outputs.customizeIconImageViewUI
            .map { OWCustomizableElement.commentingEnded(element: .icon(image: $0)) }

        let commentingReadOnlyCustomizeTitle = commentingCTAViewModel
            .outputs.commentingReadOnlyViewModel
            .outputs.customizeTitleLabelUI
            .map { OWCustomizableElement.commentingEnded(element: .title(label: $0)) }

        let commentingReadOnlyCustomizationElementsObservable = Observable.merge(commentingReadOnlyCustomizeIcon,
                                                                                 commentingReadOnlyCustomizeTitle)

        let customizationElementsObservables = Observable.merge(conversationTitleHeaderCustomizationElementsObservable,
                                                                articleDescriptionCustomizationElementsObservable,
                                                                loginPromptCustomizationElementsObservable,
                                                                summaryCustomizationElementsObservable,
                                                                communityQuestionCustomizationElementObservable,
                                                                communityGuidelinesCustomizationElementObservable,
                                                                commentCreationEntryCustomizationElementsObservable,
                                                                commentingReadOnlyCustomizationElementsObservable,
                                                                conversationEmptyStateCustomizationElementsObservable)

        customizationElementsObservables
            .subscribe { [weak self] element in
                self?.customizationsService.trigger(customizableElement: element)
            }
            .disposed(by: disposeBag)
    }
}
