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
    
    func startConversationFlow(conversationData: OWConversationRequiredData,
                               presentationalMode: OWPresentationalMode,
                               callbacks: OWViewActionsCallbacks?) -> Observable<Void> {
        invalidateExistingFlows()
        prepareRouter(presentationalMode: presentationalMode)
        
        let conversationCoordinator = OWConversationCoordinator(router: router,
                                                                conversationData: conversationData,
                                                                actionsCallbacks: callbacks)
        
        return coordinate(to: conversationCoordinator, deepLinkOptions: nil)
            .voidify()
    }
    
    // TODO: Change to pre conversation view once class will be created
    func startPreConversationFlow() -> Observable<UIView> {
        return .empty()
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
