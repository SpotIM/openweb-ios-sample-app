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
    func showAlert(title: String, message: String, actions: [UIRxPresenterAction]) -> Observable<UIAlertType>
    func showMenu(actions: [UIRxPresenterAction]) -> Observable<UIAlertType>
}

class OWPresenterService: OWPresenterServicing {
    fileprivate var routering: OWRouteringCompatible?

    init(routering: OWRouteringCompatible?) {
        self.routering = routering
    }

    func showAlert(title: String, message: String, actions: [UIRxPresenterAction]) -> Observable<UIAlertType> {
        guard let navController = routering?.routering.navigationController
        else { return .empty() }

        return UIAlertController.rx.show(onViewController: navController,
                                         preferredStyle: .alert,
                                         title: title,
                                         message: message,
                                         actions: actions)
    }

    func showMenu(actions: [UIRxPresenterAction]) -> Observable<UIAlertType> {
        // TODO: show proper menu instead of actionSheet
        guard let navController = routering?.routering.navigationController
        else { return .empty() }
        return UIAlertController.rx.show(onViewController: navController,
                                         preferredStyle: .actionSheet,
                                         title: nil,
                                         message: nil,
                                         actions: actions)
    }
}
