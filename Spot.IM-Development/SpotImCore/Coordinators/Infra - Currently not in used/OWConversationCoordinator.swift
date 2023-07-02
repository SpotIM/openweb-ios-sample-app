//
//  OWConversationCoordinator.swift
//  SpotImCore
//
//  Created by Alon Haiut on 05/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
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
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?
    fileprivate let authenticationManager: OWAuthenticationManagerProtocol
    fileprivate var viewableMode: OWViewableMode!
    fileprivate lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: actionsCallbacks, viewSourceType: .conversation)
    }()
    fileprivate lazy var customizationsService: OWCustomizationsServicing = {
        return OWCustomizationsService(viewSourceType: .conversation)
    }()

    init(router: OWRoutering! = nil,
         conversationData: OWConversationRequiredData,
         actionsCallbacks: OWViewActionsCallbacks?,
         authenticationManager: OWAuthenticationManagerProtocol = OWSharedServicesProvider.shared.authenticationManager()) {
        self.router = router
        self.conversationData = conversationData
        self.actionsCallbacks = actionsCallbacks
        self.authenticationManager = authenticationManager
    }

    // swiftlint:disable function_body_length
    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWConversationCoordinatorResult> {
        viewableMode = .partOfFlow
        let conversationVM: OWConversationViewModeling = OWConversationViewModel(conversationData: conversationData,
                                                                                 viewableMode: viewableMode)
        let conversationVC = OWConversationVC(viewModel: conversationVM)
        let conversationPopped = PublishSubject<Void>()

        setupObservers(forViewModel: conversationVM)
        setupViewActionsCallbacks(forViewModel: conversationVM)

        let deepLinkToCommentCreation = BehaviorSubject<OWCommentCreationRequiredData?>(value: nil)
        let deepLinkToCommentThread = BehaviorSubject<OWCommentThreadRequiredData?>(value: nil)

        var animated = true

        // Support deep links which related to conversation
        if let deepLink = deepLinkOptions {
            switch deepLink {
            case .commentCreation(let commentCreationData):
                animated = false
                deepLinkToCommentCreation.onNext(commentCreationData)
            case .commentThread(let commentThreadData):
                animated = false
                deepLinkToCommentThread.onNext(commentThreadData)
            case .highlightComment(let commentId):
                conversationVM.inputs.highlightComment.onNext(commentId)
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

        // CTA tapped from conversation screen
        let openCommentCreationObservable = conversationVM.outputs.conversationViewVM.outputs.openCommentCreation
            .observe(on: MainScheduler.instance)
            .map { [weak self] type -> OWCommentCreationRequiredData? in
                // Here we are generating `OWCommentCreationRequiredData` and new fields in this struct will have default values
                guard let self = self else { return nil }
                return OWCommentCreationRequiredData(article: self.conversationData.article,
                                                     settings: self.conversationData.settings,
                                                     commentCreationType: type,
                                                     presentationalStyle: self.conversationData.presentationalStyle)
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
            .flatMap { [weak self] commentCreationData -> Observable<OWCommentCreationCoordinatorResult> in
                guard let self = self else { return .empty() }
                let commentCreationCoordinator = OWCommentCreationCoordinator(router: self.router,
                                                                              commentCreationData: commentCreationData,
                                                                              actionsCallbacks: self.actionsCallbacks)
                return self.coordinate(to: commentCreationCoordinator)
            }
            .do(onNext: { result in
                switch result {
                case .commentCreated(_):
                    // TODO: We will probably would like to push this comment to the table view with a nice highlight animation
                    break
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

        // Coordinate to comment thread
        let coordinateCommentThreadObservable = deepLinkToCommentThread.unwrap().asObservable()
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return self.viewableMode == .partOfFlow
            }
            .flatMap { [weak self] commentThreadData -> Observable<OWCommentThreadCoordinatorResult> in
                guard let self = self else { return .empty() }
                let commentThreadCoordinator = OWCommentThreadCoordinator(router: self.router,
                                                                              commentThreadData: commentThreadData,
                                                                              actionsCallbacks: self.actionsCallbacks)
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

        // Coordinate to report reasons - Flow
        conversationVM.outputs
            .conversationViewVM.outputs.openReportReason
            .filter { [weak self] _ in
                guard let self = self else { return true }
                return self.viewableMode == .partOfFlow
            }
            .flatMap { [weak self] (commentId, parentId) -> Observable<OWReportReasonCoordinatorResult> in
                guard let self = self else { return .empty() }
                let reportReasonCoordinator = OWReportReasonCoordinator(commentId: commentId,
                                                                        parentId: parentId,
                                                                        router: self.router,
                                                                        actionsCallbacks: self.actionsCallbacks,
                                                                        presentationalMode: self.conversationData.presentationalStyle)

                return self.coordinate(to: reportReasonCoordinator)
            }
            .subscribe()
            .disposed(by: disposeBag)

        // URL tapped from community guidelines screen
        let communityGuidelinesURLTapped = conversationVM.outputs
            .conversationViewVM.outputs
            .communityGuidelinesCellViewModel.outputs
            .communityGuidelinesViewModel.outputs
            .urlClickedOutput

        // Coordinate to safari tab
        let coordinateToSafariObservables = Observable.merge(
            communityGuidelinesURLTapped,
            conversationVM.outputs.conversationViewVM.outputs.commentingCTAViewModel.outputs.openProfile,
            conversationVM.outputs.conversationViewVM.outputs.urlClickedOutput,
            conversationVM.outputs.conversationViewVM.outputs.openProfile
        )

        let coordinateToSafariObservable = coordinateToSafariObservables
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return self.viewableMode == .partOfFlow
            }
            .flatMap { [weak self] url -> Observable<OWSafariTabCoordinatorResult> in
                guard let self = self else { return .empty() }
                let safariCoordinator = OWSafariTabCoordinator(router: self.router,
                                                               url: url,
                                                               actionsCallbacks: self.actionsCallbacks)
                return self.coordinate(to: safariCoordinator, deepLinkOptions: .none)
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
            .map { OWConversationCoordinatorResult.popped }
            .asObservable()

        let conversationLoadedObservable = conversationVM.outputs.loadedToScreen
            .map { OWConversationCoordinatorResult.loadedToScreen }
            .asObservable()

        return Observable.merge(
            conversationPoppedObservable,
            coordinateCommentCreationObservable,
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

    func setupViewActionsCallbacks(forViewModel viewModel: OWConversationViewModeling) {
        guard actionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided
    }

    func setupObservers(forViewModel viewModel: OWConversationViewViewModeling) {
        // TODO: Setting up general observers which affect app flow however not entirely inside the SDK

        setupCustomizationElements(forViewModel: viewModel)
    }

    func setupViewActionsCallbacks(forViewModel viewModel: OWConversationViewViewModeling) {
        guard actionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided

        let closeConversationPressed = viewModel
            .outputs.conversationTitleHeaderViewModel
            .outputs.closeConversation
            .map { OWViewActionCallbackType.closeConversationPressed }

        let openPublisherProfile = Observable.merge(
            viewModel.outputs.openPublisherProfile,
            viewModel.outputs.commentingCTAViewModel.outputs.openPublisherProfile
        )
            .map { OWViewActionCallbackType.openPublisherProfile(userId: $0) }

        let openReportReason = viewModel.outputs.openReportReason
            .map { (commentId, parentId) in
                OWViewActionCallbackType.openReportReason(commentId: commentId, parentId: parentId)
            }

        Observable.merge(closeConversationPressed, openPublisherProfile, openReportReason)
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

        let communityQuestionCustomizeTitleLabel = viewModel.outputs.communityQuestionCellViewModel
            .outputs.communityQuestionViewModel
            .outputs.customizeQuestionTitleLabelUI

        let communityQuestionCustomizeTitleTextView = viewModel.outputs.communityQuestionCellViewModel
            .outputs.communityQuestionViewModel
            .outputs.customizeQuestionTitleTextViewUI

        let communityQuestionStyle = viewModel.outputs.communityQuestionCellViewModel
            .outputs.communityQuestionViewModel
            .outputs.style

        let communityQuestionCustomizationElementObservable = Observable.combineLatest(communityQuestionCustomizeContainer,
                                                                                    communityQuestionCustomizeTitleLabel,
                                                                                    communityQuestionCustomizeTitleTextView)
            .flatMap { container, titleLabel, titleTextView in
                switch communityQuestionStyle {
                case .regular:
                    return Observable.just(OWCustomizableElement.communityGuidelines(element: .regular(textView: titleTextView)))
                case .compact:
                    return Observable.just(OWCustomizableElement.communityQuestion(element: .compact(containerView: container, label: titleLabel)))
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
            .outputs.customizeTitleTextViewUI

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
                    return Observable.just(OWCustomizableElement.communityQuestion(element: .regular(textView: title)))
                case .compact:
                    return Observable.just(OWCustomizableElement.communityGuidelines(element: .compact(containerView: container, icon: icon, textView: title)))
                case .none:
                    return .empty()
                }
            }

        // Set customized conversation empty state

        let conversationEmptyStateCustomizeIcon = viewModel.outputs.conversationEmptyStateViewModel
            .outputs.customizeIconImageViewUI

        let conversationEmptyStateCustomizeTitle = viewModel.outputs.conversationEmptyStateViewModel
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
