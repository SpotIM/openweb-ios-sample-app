//
//  OWPreConversationCoordinator.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 07/09/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift

enum OWPreConversationCoordinatorResult: OWCoordinatorResultProtocol {
    case never

    var loadedToScreen: Bool {
        return false
    }
}

class OWPreConversationCoordinator: OWBaseCoordinator<OWPreConversationCoordinatorResult> {
    private var _dismissInitialVC = PublishSubject<Void>()
    var dismissInitialVC: Observable<Void> {
        return _dismissInitialVC.asObservable()
    }

    // Router is being used only for `Flows` mode. Intentionally defined as force unwrap for easy access.
    // Trying to use that in `Standalone Views` mode will cause a crash immediately.
    private var router: OWRoutering!
    private let preConversationData: OWPreConversationRequiredData
    private let viewActionsCallbacks: OWViewActionsCallbacks?
    private let flowActionsCallbacks: OWFlowActionsCallbacks?
    private var viewableMode: OWViewableMode!
    private lazy var flowActionsService: OWFlowActionsServicing = {
        return OWFlowActionsService(flowActionsCallbacks: flowActionsCallbacks, viewSourceType: .preConversation)
    }()
    private lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: viewActionsCallbacks, viewSourceType: .preConversation)
    }()
    private lazy var customizationsService: OWCustomizationsServicing = {
        return OWCustomizationsService(viewSourceType: .preConversation)
    }()

    init(router: OWRoutering! = nil,
         preConversationData: OWPreConversationRequiredData,
         viewActionsCallbacks: OWViewActionsCallbacks? = nil,
         flowActionsCallbacks: OWFlowActionsCallbacks? = nil,
         viewableMode: OWViewableMode) {
        self.router = router
        self.preConversationData = preConversationData
        self.viewActionsCallbacks = viewActionsCallbacks
        self.flowActionsCallbacks = flowActionsCallbacks
        self.viewableMode = viewableMode
    }

    override func start(coordinatorData: OWCoordinatorData? = nil) -> Observable<OWPreConversationCoordinatorResult> {
        // Pre conversation never will be a full screen
        return .empty()
    }

    override func showableComponent() -> Observable<OWShowable> {
        let preConversationViewVM: any OWPreConversationViewViewModeling = OWPreConversationViewViewModel(preConversationData: preConversationData,
                                                                                                      viewableMode: .independent)
        let preConversationView = OWPreConversationView(viewModel: preConversationViewVM)

        setupObservers(forViewModel: preConversationViewVM)
        switch viewableMode {
        case .partOfFlow:
            setupFlowActionsCallbacks(forViewModel: preConversationViewVM)
        case .independent:
            setupViewActionsCallbacks(forViewModel: preConversationViewVM)
        default:
            break
        }

        let viewObservable: Observable<OWShowable> = Observable.just(preConversationView)
            .map { $0 as OWShowable }
            .asObservable()

        return viewObservable
    }
}

private extension OWPreConversationCoordinator {
    // swiftlint:disable function_body_length
    func setupObservers(forViewModel viewModel: any OWPreConversationViewViewModeling) {
    // swiftlint:enable function_body_length
        dismissInitialVC
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                switch self.preConversationData.presentationalMode {
                case .present:
                    router.dismiss(animated: true, completion: nil)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        let openFullConversationObservable: Observable<OWCoordinatorData?> = viewModel.outputs.openFullConversation
            .map { _ -> OWCoordinatorData? in
                return nil
            }

        let openCommentCreationObservable: Observable<OWCoordinatorData?> = viewModel.outputs.openCommentCreation
            .observe(on: MainScheduler.instance)
            .map { [weak self] type -> OWCoordinatorData? in
                // 3. Perform deeplink to comment creation screen
                guard let self else { return nil }
                let commentCreationData = OWCommentCreationRequiredData(article: self.preConversationData.article,
                                                                        settings: self.preConversationData.settings,
                                                                        commentCreationType: type,
                                                                        presentationalStyle: self.preConversationData.presentationalMode)
                return OWCoordinatorData(deepLink: .commentCreation(commentCreationData: commentCreationData),
                                         source: .preConversation)
            }

        let openCommentThreadObservable = viewModel.outputs.openCommentThread
            .observe(on: MainScheduler.instance)
            .map { [weak self] commentId, performAction -> OWCoordinatorData? in
                guard let self else { return nil }
                guard var newAdditionalSettings = self.preConversationData.settings as? OWAdditionalSettings,
                      var newCommentThreadSettings = newAdditionalSettings.commentThreadSettings as? OWCommentThreadSettings
                else { return nil }

                newCommentThreadSettings.performActionType = performAction
                newAdditionalSettings.commentThreadSettings = newCommentThreadSettings

                let commentThreadData = OWCommentThreadRequiredData(article: self.preConversationData.article,
                                                   settings: newAdditionalSettings,
                                                   commentId: commentId,
                                                   presentationalMode: self.preConversationData.presentationalMode)
                return OWCoordinatorData(deepLink: .commentThread(commentThreadData: commentThreadData))
            }

        let openReportReasonObservable: Observable<OWCoordinatorData?> = viewModel.outputs.openReportReason

            .map { commentVM -> OWCoordinatorData? in
                // 3. Perform deeplink to comment creation screen
                guard let commentId = commentVM.outputs.comment.id,
                let parentId = commentVM.outputs.comment.parentId else { return nil }
                let reportData = OWReportReasonsRequiredData(commentId: commentId, parentId: parentId)
                return OWCoordinatorData(deepLink: .reportReason(reportData: reportData))
            }

        let openClarityDetailsObservable: Observable<OWCoordinatorData?> = viewModel.outputs.openClarityDetails
            .map { clarityDetailsType -> OWCoordinatorData? in
                return OWCoordinatorData(deepLink: .clarityDetails(clarityData: clarityDetailsType))
            }

        // Coordinate to full conversation
        Observable.merge(openFullConversationObservable,
                         openCommentCreationObservable,
                         openReportReasonObservable,
                         openClarityDetailsObservable,
                         openCommentThreadObservable)
            .filter { [weak self] _ in
                guard let self else { return true }
                return self.viewableMode == .partOfFlow
            }
            .flatMapLatest { [weak self] coordinatorData -> Observable<OWConversationCoordinatorResult> in
                guard let self else { return .empty() }
                let conversationData = OWConversationRequiredData(article: self.preConversationData.article,
                                                                  settings: self.preConversationData.settings,
                                                                  presentationalMode: self.preConversationData.presentationalMode)
                let conversationCoordinator = OWConversationCoordinator(router: self.router,
                                                                        conversationData: conversationData,
                                                                        viewActionsCallbacks: self.viewActionsCallbacks,
                                                                        flowActionsCallbacks: self.flowActionsCallbacks)
                return self.coordinate(to: conversationCoordinator, coordinatorData: coordinatorData)
            }
            .do(onNext: { [weak self] coordinatorResult in
                guard let self else { return }
                switch coordinatorResult {
                case .popped:
                    self._dismissInitialVC.onNext()
                default:
                    break
                }
            })
            .subscribe()
            .disposed(by: disposeBag)

        // Coordinate to safari tab
        let coordinateToSafariObservables = Observable.merge(
            viewModel.outputs.communityGuidelinesViewModel.outputs.urlClickedOutput.map { OWWebTabOptions(url: $0) },
            viewModel.outputs.urlClickedOutput.map { OWWebTabOptions(url: $0) },
            viewModel.outputs.footerViewViewModel.outputs.urlClickedOutput.map { OWWebTabOptions(url: $0) },
            viewModel.outputs.openProfile.map {
                if case .OWProfile(let data) = $0 {
                    return OWWebTabOptions(url: data.url, title: OWLocalizationManager.shared.localizedString(key: "ProfileTitle"))
                } else {
                    return nil
                }
            }.unwrap()
        )

        coordinateToSafariObservables
            .filter { [weak self] _ in
                guard let self else { return true }
                return self.viewableMode == .partOfFlow
            }
            .flatMap { [weak self] options -> Observable<OWWebTabCoordinatorResult> in
                guard let self else { return .empty() }
                let safariCoordinator = OWWebTabCoordinator(router: self.router,
                                                                   options: options,
                                                                   viewActionsCallbacks: self.viewActionsCallbacks)
                return self.coordinate(to: safariCoordinator, coordinatorData: nil)
            }
            .do(onNext: { [weak self] coordinatorResult in
                guard let self else { return }
                switch coordinatorResult {
                case .popped:
                    self._dismissInitialVC.onNext()
                default:
                    break
                }
            })
            .subscribe()
            .disposed(by: disposeBag)

        setupCustomizationElements(forViewModel: viewModel)
    }

    func setupFlowActionsCallbacks(forViewModel viewModel: any OWPreConversationViewViewModeling) {
        guard flowActionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided

        let openPublisherProfile = viewModel.outputs.openProfile
            .map { [weak self] openProfileType -> OWFlowActionCallbackType? in
                guard let self else { return nil }
                return self.flowActionsService.getOpenProfileActionCallback(for: self.router.navigationController,
                                                                            openProfileType: openProfileType,
                                                                            presentationalModeCompact: self.preConversationData.presentationalMode)
            }
            .unwrap()
            .asObservable()

        Observable.merge(openPublisherProfile)
            .subscribe(onNext: { [weak self] flowActionType in
                self?.flowActionsService.append(flowAction: flowActionType)
            })
            .disposed(by: disposeBag)
    }

    func setupViewActionsCallbacks(forViewModel viewModel: any OWPreConversationViewViewModeling) {
        guard viewActionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided

        let contentPressed = viewModel.outputs.openFullConversation
            .map { OWViewActionCallbackType.contentPressed }

        let termsTapped = viewModel.outputs.termsTapped
            .map { OWViewActionCallbackType.termsTapped }

        let privacyTapped = viewModel.outputs.privacyTapped
            .map { OWViewActionCallbackType.privacyTapped }

        let openPublisherProfile = viewModel.outputs.openProfile
            .map { openProfileType in
                switch openProfileType {
                case .OWProfile(let data):
                    return OWViewActionCallbackType.openOWProfile(data: data)
                case .publisherProfile(let ssoPublisherId, let type):
                    return OWViewActionCallbackType.openPublisherProfile(ssoPublisherId: ssoPublisherId, type: type)
                }
            }
            .asObservable()

        let openReportReason = viewModel.outputs.openReportReason
            .map { commentVM -> OWViewActionCallbackType in
                guard let commentId = commentVM.outputs.comment.id,
                      let parentId = commentVM.outputs.comment.parentId else { return .error(.reportReasonFlow) }
                return OWViewActionCallbackType.openReportReason(commentId: commentId, parentId: parentId)
            }

        // Open Guidelines
        let communityGuidelinesObservable = viewModel.outputs.communityGuidelinesViewModel.outputs.urlClickedOutput
            .map { OWViewActionCallbackType.communityGuidelinesPressed(url: $0) }

        // Open comment creation
        let commentCreationObservable = viewModel.outputs.openCommentCreation
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

        Observable.merge(contentPressed,
                         openPublisherProfile,
                         openReportReason,
                         communityGuidelinesObservable,
                         commentCreationObservable,
                         termsTapped,
                         privacyTapped)
            .subscribe(onNext: { [weak self] viewActionType in
                self?.viewActionsService.append(viewAction: viewActionType)
            })
            .disposed(by: disposeBag)
    }

    // swiftlint:disable function_body_length
    func setupCustomizationElements(forViewModel viewModel: any OWPreConversationViewViewModeling) {
        // swiftlint:enable function_body_length

        // Set customized pre conversation summary header
        let summaryHeaderCustomizeTitle = viewModel.outputs.preConversationSummaryVM
            .outputs.customizeTitleLabelUI
            .map { OWCustomizableElement.summaryHeader(element: .title(label: $0)) }

        let summaryHeaderCustomizeCounter = viewModel.outputs.preConversationSummaryVM
            .outputs.customizeCounterLabelUI
            .map { OWCustomizableElement.summaryHeader(element: .counter(label: $0)) }

        let summaryHeaderCustomizeOnlineUsersIcon = viewModel.outputs.preConversationSummaryVM
            .outputs.onlineViewingUsersVM
            .outputs.customizeIconImageUI
            .map { OWCustomizableElement.onlineUsers(element: .icon(image: $0)) }

        let summaryHeaderCustomizeOnlineUsersCounter = viewModel.outputs.preConversationSummaryVM
            .outputs.onlineViewingUsersVM
            .outputs.customizeCounterLabelUI
            .map { OWCustomizableElement.onlineUsers(element: .counter(label: $0)) }

        let summaryCustomizationElementsObservable = Observable.merge(summaryHeaderCustomizeTitle,
                                                                      summaryHeaderCustomizeCounter,
                                                                      summaryHeaderCustomizeOnlineUsersIcon,
                                                                      summaryHeaderCustomizeOnlineUsersCounter)

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

        // Set customized community question
        let communityQuestionCustomizeContainer = viewModel.outputs.communityQuestionViewModel
            .outputs.customizeQuestionContainerViewUI

        let communityQuestionCustomizeTitle = viewModel.outputs.communityQuestionViewModel
            .outputs.customizeQuestionTitleLabelUI

        let communityQuestionStyle = viewModel.outputs.communityQuestionViewModel
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
        let communityGuidelinesCustomizeContainer = viewModel.outputs.communityGuidelinesViewModel
            .outputs.customizeContainerViewUI

        let communityGuidelinesCustomizeTitle = viewModel.outputs.communityGuidelinesViewModel
            .outputs.customizeTitleLabelUI

        let communityGuidelinesCustomizeIcon = viewModel.outputs.communityGuidelinesViewModel
            .outputs.customizeIconImageViewUI

        let communityGuidelinesStyle = viewModel.outputs.communityGuidelinesViewModel
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

        let customizationElementsObservables = Observable.merge(summaryCustomizationElementsObservable,
                                                                loginPromptCustomizationElementsObservable,
                                                                communityQuestionCustomizationElementObservable,
                                                                communityGuidelinesCustomizationElementObservable,
                                                                commentCreationEntryCustomizationElementsObservable,
                                                                commentingReadOnlyCustomizationElementsObservable)

        customizationElementsObservables
            .subscribe { [weak self] element in
                self?.customizationsService.trigger(customizableElement: element)
            }
            .disposed(by: disposeBag)
    }
}
