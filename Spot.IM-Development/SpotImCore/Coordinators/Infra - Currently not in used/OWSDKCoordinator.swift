//
//  OWSDKCoordinator.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

class OWSDKCoordinator: OWBaseCoordinator<Void> {
    fileprivate var router: OWRoutering!
    
    func startPreConversationFlow(preConversationData: OWPreConversationRequiredData,
                                  presentationalMode: OWPresentationalMode,
                                  callbacks: OWViewActionsCallbacks?) -> Observable<OWViewDynamicSizeOption> {
        invalidateExistingFlows()
        prepareRouter(presentationalMode: presentationalMode, presentAnimated: true)
        
        return Observable.just(())
            .observe(on: MainScheduler.instance)
            .flatMap { [ weak self] _ -> Observable<OWViewDynamicSizeOption> in
                guard let self = self else { return .empty() }
                let preConversationCoordinator = OWPreConversationCoordinator(router: self.router,
                                                                        preConversationData: preConversationData,
                                                                        actionsCallbacks: callbacks)
                
                self.store(coordinator: preConversationCoordinator)
                return preConversationCoordinator.showableComponentDynamicSize()
            }
    }
    
    func startConversationFlow(conversationData: OWConversationRequiredData,
                               presentationalMode: OWPresentationalMode,
                               callbacks: OWViewActionsCallbacks?,
                               deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWConversationCoordinatorResult> {
        invalidateExistingFlows()
        
        var presentAnimated: Bool = true
        if let deepLink = deepLinkOptions, case .commentCreation(_) = deepLink {
            presentAnimated = false
        }
        
        prepareRouter(presentationalMode: presentationalMode, presentAnimated: presentAnimated)
        
        let conversationCoordinator = OWConversationCoordinator(router: router,
                                                                conversationData: conversationData,
                                                                actionsCallbacks: callbacks)
        
        return coordinate(to: conversationCoordinator, deepLinkOptions: deepLinkOptions)
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
}

fileprivate extension OWSDKCoordinator {
    func prepareRouter(presentationalMode: OWPresentationalMode, presentAnimated: Bool) {
        invalidateExistingFlows()
        
        let navigationController: UINavigationController
        
        switch presentationalMode {
        case .present(let viewController):
            navigationController = OWNavigationController.shared
            (navigationController as? OWNavigationController)?.clear()
            // TODO: We can later on work on a custom transition which looks like the old `present` which cover the whole screen
            viewController.present(navigationController, animated: presentAnimated)
        case .push(let navController):
            navigationController = navController
        }
        
        router = OWRouter(navigationController: navigationController)
    }
    
    func invalidateExistingFlows() {
        removeAllChildCoordinators()
    }
}
