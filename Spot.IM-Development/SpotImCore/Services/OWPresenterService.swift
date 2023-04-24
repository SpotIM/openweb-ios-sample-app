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
    func showAlert() -> Observable<UIAlertType>
    func showPopoverOptions(source: UIView?) -> Observable<UIAlertType>
}

class OWPresenterService: OWPresenterServicing {
    fileprivate var routering: OWRouteringCompatible? // weak ?
//    fileprivate weak var viewCoordinator: OWViewsSDKCoordinator?

    init(routering: OWRouteringCompatible?) {
        self.routering = routering
    }

    // TODO
    func showAlert() -> Observable<UIAlertType> {
        guard let navController = routering?.routering.navigationController
        else { return .empty() }

        // TODO: alert content :)
        return UIAlertController.rx.show(onViewController: navController,
                                         title: "ALERT",
                                         message: LocalizationManager.localizedString(key: "No available options"),
                                         actions: [.init(title: "close", style: .cancel)])
    }

    func showPopoverOptions(source: UIView?) -> Observable<UIAlertType> {
        guard let navController = routering?.routering.navigationController
        else { return .empty() }

        // TODO: alert content :)
        return UIPopoverPresentationController.rx.show(onViewController: navController,
                                                       sourceView: source,
                                                       title: "POPOVERR",
                                                       message: LocalizationManager.localizedString(key: "No available options"),
                                                       actions: [.init(title: "close", style: .cancel), .init(title: "optionnn", style: .default)])
    }
}
