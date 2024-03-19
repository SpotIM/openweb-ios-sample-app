//
//  OWSDKCoordinator.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWFlowsSDKCoordinator: OWBaseCoordinator<Void>, OWRouteringCompatible {
    fileprivate var router: OWRoutering!
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let uiDevice: UIDevice

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         uiDevice: UIDevice = UIDevice.current) {
        self.servicesProvider = servicesProvider
        self.uiDevice = uiDevice
    }

    var routering: OWRoutering {
        return router
    }

    func startPreConversationFlow(preConversationData: OWPreConversationRequiredData,
                                  presentationalMode: OWPresentationalMode,
                                  callbacks: OWViewActionsCallbacks?) -> Observable<OWShowable> {

        return Observable.just(())
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.invalidateExistingFlows()
                self.generateNewPageViewId()
                self.prepareRouter(presentationalMode: presentationalMode, presentAnimated: true)
            })
            .flatMap { [ weak self] _ -> Observable<OWShowable> in
                guard let self = self else { return .empty() }

                let preConversationCoordinator = OWPreConversationCoordinator(router: self.router,
                                                                              preConversationData: preConversationData,
                                                                              actionsCallbacks: callbacks,
                                                                              viewableMode: .partOfFlow)
                self.store(coordinator: preConversationCoordinator)

                return preConversationCoordinator.showableComponent()
            }
    }

    func startConversationFlow(conversationData: OWConversationRequiredData,
                               presentationalMode: OWPresentationalMode,
                               callbacks: OWViewActionsCallbacks?,
                               coordinatorData: OWCoordinatorData? = nil) -> Observable<OWConversationCoordinatorResult> {
        invalidateExistingFlows()
        generateNewPageViewId()
        prepareRouter(presentationalMode: presentationalMode, presentAnimated: true)

        let conversationCoordinator = OWConversationCoordinator(router: router,
                                                                conversationData: conversationData,
                                                                actionsCallbacks: callbacks)

        return coordinate(to: conversationCoordinator, coordinatorData: coordinatorData)
            .do { [weak self] coordinatorResult in
                guard let self = self else { return }
                if coordinatorResult == .popped {
                    self.cleanRouter(presentationalMode: presentationalMode)
                }
            }
    }

    func startCommentCreationFlow(conversationData: OWConversationRequiredData,
                                  commentCreationData: OWCommentCreationRequiredData,
                                  presentationalMode: OWPresentationalMode,
                                  callbacks: OWViewActionsCallbacks?) -> Observable<OWConversationCoordinatorResult> {

        let coordinatorData = OWCoordinatorData(deepLink: .commentCreation(commentCreationData: commentCreationData),
                                            source: .conversation)
        return startConversationFlow(conversationData: conversationData,
                                     presentationalMode: presentationalMode,
                                     callbacks: callbacks,
                                     coordinatorData: coordinatorData)
    }

    func startCommentThreadFlow(conversationData: OWConversationRequiredData,
                                commentThreadData: OWCommentThreadRequiredData,
                                presentationalMode: OWPresentationalMode,
                                callbacks: OWViewActionsCallbacks?) -> Observable<OWConversationCoordinatorResult> {

        let coordinatorData = OWCoordinatorData(deepLink: .commentThread(commentThreadData: commentThreadData))
        return startConversationFlow(conversationData: conversationData,
                                     presentationalMode: presentationalMode,
                                     callbacks: callbacks,
                                     coordinatorData: coordinatorData)
    }

#if BETA
    func startTestingPlaygroundFlow(testingPlaygroundData: OWTestingPlaygroundRequiredData,
                                    presentationalMode: OWPresentationalMode,
                                    callbacks: OWViewActionsCallbacks?,
                                    coordinatorData: OWCoordinatorData? = nil) -> Observable<OWTestingPlaygroundCoordinatorResult> {
        invalidateExistingFlows()

        prepareRouter(presentationalMode: presentationalMode, presentAnimated: true)

        let testingPlaygroundCoordinator = OWTestingPlaygroundCoordinator(router: router,
                                                                          testingPlaygroundData: testingPlaygroundData,
                                                                          actionsCallbacks: callbacks)

        return coordinate(to: testingPlaygroundCoordinator, coordinatorData: coordinatorData)
    }
#endif

#if AUTOMATION
    func startFontsFlow(automationData: OWAutomationRequiredData,
                        presentationalMode: OWPresentationalMode,
                        callbacks: OWViewActionsCallbacks?,
                        coordinatorData: OWCoordinatorData? = nil) -> Observable<OWFontsCoordinatorResult> {
        invalidateExistingFlows()

        prepareRouter(presentationalMode: presentationalMode, presentAnimated: true)

        let fontsAutomationCoordinator = OWFontsCoordinator(router: router,
                                                            automationData: automationData,
                                                            actionsCallbacks: callbacks)

        return coordinate(to: fontsAutomationCoordinator, coordinatorData: coordinatorData)
    }

    func startUserStatusFlow(automationData: OWAutomationRequiredData,
                             presentationalMode: OWPresentationalMode,
                             callbacks: OWViewActionsCallbacks?,
                             coordinatorData: OWCoordinatorData? = nil) -> Observable<OWUserStatusCoordinatorResult> {
        invalidateExistingFlows()

        prepareRouter(presentationalMode: presentationalMode, presentAnimated: true)

        let userStatusCoordinator = OWUserStatusCoordinator(router: router,
                                                            automationData: automationData,
                                                            actionsCallbacks: callbacks)

        return coordinate(to: userStatusCoordinator, coordinatorData: coordinatorData)
    }
#endif
}

fileprivate extension OWFlowsSDKCoordinator {
    func prepareRouter(presentationalMode: OWPresentationalMode, presentAnimated: Bool) {
        invalidateExistingFlows()

        let navController: UINavigationController
        let shouldCustomizeNavController: Bool
        let presentationalModeExtended: OWPresentationalModeExtended
        let navCustomizerService = servicesProvider.navigationControllerCustomizer()

        // Initializes the orientation for first time
        let orientationService = servicesProvider.orientationService()
        orientationService.set(viewableMode: .partOfFlow)

        switch presentationalMode {
        case .present(let viewController, let style):

            var adjustedStyle = style
            if orientationService.interfaceOrientationMask == .landscape,
                self.uiDevice.userInterfaceIdiom == .phone,
                style == .pageSheet {
                // Force full screen presentation in landscape mode for iPhone because page sheet not supported in landscape
                adjustedStyle = .fullScreen
            }

            shouldCustomizeNavController = true // Always customize internal nav controller
            navController = OWNavigationController.shared
            navController.modalPresentationStyle = adjustedStyle.toOSModalPresentationStyle
            presentationalModeExtended = OWPresentationalModeExtended.present(viewControllerWeakEncapsulation: OWWeakEncapsulation(value: viewController),
                                                                              style: adjustedStyle,
                                                                              animated: presentAnimated)
        case .push(let navigationController):
            navController = navigationController
            presentationalModeExtended = OWPresentationalModeExtended.push(navigationController: navController)
            shouldCustomizeNavController = navCustomizerService.shouldCustomizeNavigationController()
        }

        // Customize navigation controller if needed
        if shouldCustomizeNavController {
            navCustomizerService.activeNavigationController(navigationController: navController)
        }

        router = OWRouter(navigationController: navController, presentationalMode: presentationalModeExtended)
    }

    func cleanRouter(presentationalMode: OWPresentationalMode) {
        switch presentationalMode {
        case .present(viewController: _):
            router.dismiss(animated: true, completion: nil)
        default:
            break
        }
    }

    func invalidateExistingFlows() {
        removeAllChildCoordinators()
    }

    func generateNewPageViewId() {
        let pageViewIdHolder = servicesProvider.pageViewIdHolder()
        pageViewIdHolder.generateNewPageViewId()
    }
}
