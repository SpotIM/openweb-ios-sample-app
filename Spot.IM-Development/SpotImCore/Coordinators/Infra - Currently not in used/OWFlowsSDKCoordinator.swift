//
//  OWSDKCoordinator.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

class OWFlowsSDKCoordinator: OWBaseCoordinator<Void>, OWRouteringCompatible {
    fileprivate var router: OWRoutering!
    fileprivate let servicesProvider: OWSharedServicesProviding

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
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

                    let dissmissConversation = preConversationCoordinator.dissmissConversation
                        .do(onNext: { [weak self] in
                            guard let self = self else { return }
                            self.cleanRouter(presentationalMode: presentationalMode)
                        })
                        .map { _ -> OWShowable? in
                            return nil
                        }
                        .unwrap()

                    return Observable.merge(dissmissConversation,
                                            preConversationCoordinator.showableComponent())
                }
    }

    func startConversationFlow(conversationData: OWConversationRequiredData,
                               presentationalMode: OWPresentationalMode,
                               callbacks: OWViewActionsCallbacks?,
                               deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWConversationCoordinatorResult> {
        invalidateExistingFlows()
        generateNewPageViewId()
        prepareRouter(presentationalMode: presentationalMode, presentAnimated: true)

        let conversationCoordinator = OWConversationCoordinator(router: router,
                                                                conversationData: conversationData,
                                                                actionsCallbacks: callbacks)

        return coordinate(to: conversationCoordinator, deepLinkOptions: deepLinkOptions)
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

        let deepLink = OWDeepLinkOptions.commentCreation(commentCreationData: commentCreationData)
        return startConversationFlow(conversationData: conversationData,
                                     presentationalMode: presentationalMode,
                                     callbacks: callbacks,
                                     deepLinkOptions: deepLink)
    }

    func startCommentThreadFlow(conversationData: OWConversationRequiredData,
                                commentThreadData: OWCommentThreadRequiredData,
                                presentationalMode: OWPresentationalMode,
                                callbacks: OWViewActionsCallbacks?) -> Observable<OWConversationCoordinatorResult> {

        let deepLink = OWDeepLinkOptions.commentThread(commentThreadData: commentThreadData)
        return startConversationFlow(conversationData: conversationData,
                                     presentationalMode: presentationalMode,
                                     callbacks: callbacks,
                                     deepLinkOptions: deepLink)
    }

#if BETA
    func startTestingPlaygroundFlow(testingPlaygroundData: OWTestingPlaygroundRequiredData,
                                    presentationalMode: OWPresentationalMode,
                                    callbacks: OWViewActionsCallbacks?,
                                    deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWTestingPlaygroundCoordinatorResult> {
        invalidateExistingFlows()

        prepareRouter(presentationalMode: presentationalMode, presentAnimated: true)

        let testingPlaygroundCoordinator = OWTestingPlaygroundCoordinator(router: router,
                                                                          testingPlaygroundData: testingPlaygroundData,
                                                                          actionsCallbacks: callbacks)

        return coordinate(to: testingPlaygroundCoordinator, deepLinkOptions: deepLinkOptions)
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

        switch presentationalMode {
        case .present(let viewController, let style):
            shouldCustomizeNavController = true // Always customize internal nav controller
            navController = OWNavigationController.shared
            navController.modalPresentationStyle = style.toOSModalPresentationStyle
            presentationalModeExtended = OWPresentationalModeExtended.present(viewController: viewController,
                                                                              style: style,
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
