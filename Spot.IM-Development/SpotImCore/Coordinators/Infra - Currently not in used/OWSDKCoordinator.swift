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
    
    // TODO: Complete pre conversation flow
    func startPreConversationFlow() -> Observable<OWPreConversationView> {
        return .empty()
    }
    
    func startConversationFlow(conversationData: OWConversationRequiredData,
                               presentationalMode: OWPresentationalMode,
                               callbacks: OWViewActionsCallbacks?,
                               deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<Void> {
        invalidateExistingFlows()
        prepareRouter(presentationalMode: presentationalMode)
        
        let conversationCoordinator = OWConversationCoordinator(router: router,
                                                                conversationData: conversationData,
                                                                actionsCallbacks: callbacks)
        
        return coordinate(to: conversationCoordinator, deepLinkOptions: deepLinkOptions)
            .voidify()
    }
    
    func startCommentCreationFlow(conversationData: OWConversationRequiredData,
                                  commentCreationData: OWCommentCreationRequiredData,
                               presentationalMode: OWPresentationalMode,
                               callbacks: OWViewActionsCallbacks?) -> Observable<Void> {
        
        let deepLink = OWDeepLinkOptions.commentCreation(commentCreationData: commentCreationData)
        return startConversationFlow(conversationData: conversationData,
                                     presentationalMode: presentationalMode,
                                     callbacks: callbacks,
                                     deepLinkOptions: deepLink)
    }
}

fileprivate extension OWSDKCoordinator {
    func prepareRouter(presentationalMode: OWPresentationalMode) {
        invalidateExistingFlows()
        
        let navigationController: UINavigationController
        
        switch presentationalMode {
        case .present(_):
            navigationController = OWNavigationController()
        case .push(let navController):
            navigationController = navController
        }
        
        router = OWRouter(navigationController: navigationController)
    }
    
    func invalidateExistingFlows() {
        removeAllChildCoordinators()
    }
}
