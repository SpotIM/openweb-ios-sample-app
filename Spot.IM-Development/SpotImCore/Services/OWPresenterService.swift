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
    func showAlert(title: String, message: String, actions: [UIRxAction]) -> Observable<UIAlertType>
    func showMenu(source: UIButton, actions: [UIRxAction]) -> Observable<UIAlertType>
}

class OWPresenterService: OWPresenterServicing {
    fileprivate var routering: OWRouteringCompatible?

    init(routering: OWRouteringCompatible?) {
        self.routering = routering
    }

    func showAlert(title: String, message: String, actions: [UIRxAction]) -> Observable<UIAlertType> {
        guard let navController = routering?.routering.navigationController
        else { return .empty() }

        return UIAlertController.rx.show(onViewController: navController,
                                         preferredStyle: .alert,
                                         title: title,
                                         message: message,
                                         actions: actions)
    }

    func showMenu(source: UIButton, actions: [UIRxAction]) -> Observable<UIAlertType> {
        // Add UIMenu for iOS 14+
        if #available(iOS 14.0, *) {
            return UIMenu.rx.show(onButton: source, actions: actions)
        } else {
            // Fallback on earlier versions - show actionSheet
            guard let navController = routering?.routering.navigationController
            else { return .empty() }
            return UIAlertController.rx.show(onViewController: navController,
                                             preferredStyle: .actionSheet,
                                             title: nil,
                                             message: nil,
                                             actions: actions)
        }
    }
}
