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
    
    func startConversationFlow() -> Observable<OWConversationVC> {
        return .empty()
    }
    
    // TODO: Change to pre conversation view once class will be created
    func startPreConversationFlow() -> Observable<UIView> {
        return .empty()
    }
}

fileprivate extension OWSDKCoordinator {
    // TODO: Complete
    func prepareForFlow(presentationalMode: OWPresentationalMode) {
        invalidExistingFlows()
        
        let navigationController: UINavigationController
        
        switch presentationalMode {
        case .present(_):
            navigationController = self.createNavController()
        case .push(let navController):
            navigationController = navController
        }
        
        router = OWRouter(navigationController: navigationController)
    }
    
    // TODO: Complete
    func invalidExistingFlows() {
        
    }
    
    func createNavController() -> UINavigationController {
        let navController = UINavigationController()
        // TODO: Customization and such
        
        return navController
    }
}
