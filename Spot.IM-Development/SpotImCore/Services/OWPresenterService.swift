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
    func showAlert()
    func showPopoverOptions()
}

class OWPresenterService: OWPresenterServicing {
    fileprivate var routering: OWRouteringCompatible? // weak ?
//    fileprivate weak var viewCoordinator: OWViewsSDKCoordinator?

    init(routering: OWRouteringCompatible?) {
        self.routering = routering
    }

    // TODO
    func showAlert() {
        guard let navController = routering?.routering.navigationController
        else { return }

        _ = UIAlertController.rx.show(onViewController: navController, title: "ALERT",
                                  message: LocalizationManager.localizedString(key: "No available options"),
                                  actions: [])
            .take(2) // Taking 2 cause the first one is the completion. No need to dispose cause the whole subscription will finish when the user select an option
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .completion:
                    // Do nothing
                    break
                case .selected(let action):
                    break
                }
            })
    }

    func showPopoverOptions() { }
}
