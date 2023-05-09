//
//  OWPresenterService.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 18/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWPresenterServicing {
    // should get viewable mode - and show accordingly using the OWRouteringCompatible
    func showAlert(title: String, message: String, actions: [UIRxPresenterAction], viewableMode: OWViewableMode) -> Observable<UIAlertType>
    func showMenu(actions: [UIRxPresenterAction], viewableMode: OWViewableMode) -> Observable<UIAlertType>
}

class OWPresenterService: OWPresenterServicing {

    func showAlert(title: String, message: String, actions: [UIRxPresenterAction], viewableMode: OWViewableMode) -> Observable<UIAlertType> {
        guard let navController = getViewController(for: viewableMode)
        else { return .empty() }

        return UIAlertController.rx.show(onViewController: navController,
                                         preferredStyle: .alert,
                                         title: title,
                                         message: message,
                                         actions: actions)
    }

    func showMenu(actions: [UIRxPresenterAction], viewableMode: OWViewableMode) -> Observable<UIAlertType> {
        // TODO: show proper menu instead of actionSheet
        guard let navController = getViewController(for: viewableMode)
        else { return .empty() }
        return UIAlertController.rx.show(onViewController: navController,
                                         preferredStyle: .actionSheet,
                                         title: nil,
                                         message: nil,
                                         actions: actions)
    }
}

fileprivate extension OWPresenterService {
    func getViewController(for viewableMode: OWViewableMode) -> UIViewController? {
        switch(viewableMode) {
        case .independent:
            return (OWManager.manager.uiLayer as? OWCompactRouteringCompatible)?.compactRoutering.topController
        case .partOfFlow:
            return (OWManager.manager.uiLayer as? OWRouteringCompatible)?.routering.navigationController
        }
    }
}
