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
                               callbacks: OWViewActionsCallbacks?) -> Observable<OWConversationVC> {
        invalidExistingFlows()
        prepareRouter(presentationalMode: presentationalMode)
        return .empty()
    }
    
    // TODO: Change to pre conversation view once class will be created
    func startPreConversationFlow() -> Observable<UIView> {
        return .empty()
    }
}

fileprivate extension OWSDKCoordinator {
    func prepareRouter(presentationalMode: OWPresentationalMode) {
        invalidExistingFlows()
        
        let navigationController: UINavigationController
        
        switch presentationalMode {
        case .present(_):
            navigationController = OWNavigationController()
        case .push(let navController):
            navigationController = navController
        }
        
        router = OWRouter(navigationController: navigationController)
    }
    
    // TODO: Complete
    func invalidExistingFlows() {
        removeAllChildCoordinators()
    }
}
