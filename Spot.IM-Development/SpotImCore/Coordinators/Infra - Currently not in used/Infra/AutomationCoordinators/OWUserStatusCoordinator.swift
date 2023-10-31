//
//  OWUserStatusCoordinator.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

#if AUTOMATION

/*
 This coordinator file will compile only under `AUTOMATION` flag.
 */

enum OWUserStatusCoordinatorResult: OWCoordinatorResultProtocol {
    case popped
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

class OWUserStatusCoordinator: OWBaseCoordinator<OWUserStatusCoordinatorResult> {

    // Router is being used only for `Flows` mode. Intentionally defined as force unwrap for easy access.
    // Trying to use that in `Standalone Views` mode will cause a crash immediately.
    fileprivate let router: OWRoutering!
    fileprivate let automationData: OWAutomationRequiredData

    init(router: OWRoutering! = nil, automationData: OWAutomationRequiredData, actionsCallbacks: OWViewActionsCallbacks?) {
        self.router = router
        self.automationData = automationData
    }

    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWUserStatusCoordinatorResult> {

        let userStatusVM = OWUserStatusAutomationViewModel()
        let userStatusVC = OWUserStatusAutomationVC(viewModel: userStatusVM)

        let userStatusPopped = PublishSubject<Void>()

        // Testing playground is the initial view in the router so here we start the router
        router.start()

        if router.isEmpty() {
            router.setRoot(userStatusVC, animated: false, dismissCompletion: userStatusPopped)
        } else {
            router.push(userStatusVC,
                        pushStyle: .regular,
                        animated: true,
                        popCompletion: userStatusPopped)
        }

        let userStatusPoppedObservable = userStatusPopped
            .map { OWUserStatusCoordinatorResult.popped }
            .asObservable()

        return Observable.merge(
            userStatusPoppedObservable
        )
    }

    override func showableComponent() -> Observable<OWShowable> {
        let userStatusViewVM = OWUserStatusAutomationViewViewModel()
        let userStatusView = OWUserStatusAutomationView(viewModel: userStatusViewVM)

        return .just(userStatusView)
    }
}

#endif
