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
    // TODO: should return some observable for actions
    func showAlert(title: String, message: String, actions: [UIRxAlertAction]) -> Observable<UIAlertType>
    func showMenu(source: UIButton?, actions: [UIRxAlertAction]) -> Observable<UIAlertType>
}

class OWPresenterService: OWPresenterServicing {
    fileprivate var routering: OWRouteringCompatible? // weak ?
//    fileprivate weak var viewCoordinator: OWViewsSDKCoordinator?

    init(routering: OWRouteringCompatible?) {
        self.routering = routering
    }

    // TODO
    func showAlert(title: String, message: String, actions: [UIRxAlertAction]) -> Observable<UIAlertType> {
        guard let navController = routering?.routering.navigationController
        else { return .empty() }

        return UIAlertController.rx.show(onViewController: navController,
                                         preferredStyle: .alert,
                                         title: title,
                                         message: message,
                                         actions: actions)
    }

    func showMenu(source: UIButton?, actions: [UIRxAlertAction]) -> Observable<UIAlertType> {
        // Add UIMenu for iOS 14+
        if #available(iOS 14.0, *) {
            guard let source = source else { return .empty() }
            // TODO: items
            let menuItems: [UIAction] = actions.map {
                var action = UIAction(title: $0.title, handler: {_ in })
                action.state = .on
                return action
            }
            var menu: UIMenu {
                return UIMenu(identifier: nil, options: [], children: menuItems)
            }
            source.menu = menu
            source.showsMenuAsPrimaryAction = true
            return .empty()
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
