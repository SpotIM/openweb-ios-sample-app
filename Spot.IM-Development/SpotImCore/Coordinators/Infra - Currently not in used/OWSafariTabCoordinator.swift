//
//  OWSafariTabCoordinator.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 09/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SafariServices

// TODO
enum OWSafariTabCoordinatorResult: OWCoordinatorResultProtocol {
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

class OWSafariTabCoordinator: OWBaseCoordinator<OWSafariTabCoordinatorResult> {
    
    fileprivate let router: OWRoutering
    fileprivate let url: URL
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?
    
    init(router: OWRoutering, url: URL, actionsCallbacks: OWViewActionsCallbacks?) {
        self.router = router
        self.url = url
        self.actionsCallbacks = actionsCallbacks // TODO: handle actions callbacks?
    }
    
    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWSafariTabCoordinatorResult> {
        let safariOptions = OWSafariViewControllerOptions(url: url)
        let safariVC = OWSafariViewController(options: safariOptions)
        
        let safariVCPopped = PublishSubject<Void>()
        
        router.present(safariVC, animated: true, dismissCompletion: safariVCPopped)
        return .empty() // TODO: complete with propper result
    }
}
