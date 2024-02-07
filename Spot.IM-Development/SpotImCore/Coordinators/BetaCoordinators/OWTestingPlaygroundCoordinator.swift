//
//  OWTestingPlaygroundCoordinator.swift
//  SpotImCore
//
//  Created by Alon Haiut on 22/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

#if BETA

/*
 This coordinator file will compile only under `BETA` flag.
 Note that once the new API will be ready, this will still be under `BETA` flag and will be used to easily test new features.
 */

enum OWTestingPlaygroundCoordinatorResult: OWCoordinatorResultProtocol {
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

class OWTestingPlaygroundCoordinator: OWBaseCoordinator<OWTestingPlaygroundCoordinatorResult> {

    // Router is being used only for `Flows` mode. Intentionally defined as force unwrap for easy access.
    // Trying to use that in `Standalone Views` mode will cause a crash immediately.
    fileprivate let router: OWRoutering!
    fileprivate let testingPlaygroundData: OWTestingPlaygroundRequiredData

    init(router: OWRoutering! = nil, testingPlaygroundData: OWTestingPlaygroundRequiredData, actionsCallbacks: OWViewActionsCallbacks?) {
        self.router = router
        self.testingPlaygroundData = testingPlaygroundData
    }

    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWTestingPlaygroundCoordinatorResult> {

        // Add the VC and VM you would like to test
//        let someVM: OWSomeViewModeling = ...
//        let someVC = OWSomeVC(viewModel: someVM)
        let someVM = OWTestingRxTableViewAnimationsViewModel()
        let someVC = OWTestingRxTableViewAnimationsVC(viewModel: someVM)

        let testingPlaygroundPopped = PublishSubject<Void>()

        // Testing playground is the initial view in the router so here we start the router
        router.start()

        if router.isEmpty() {
            router.setRoot(someVC, animated: false, dismissCompletion: testingPlaygroundPopped)
        } else {
            router.push(someVC,
                        pushStyle: .regular,
                        animated: true,
                        popCompletion: testingPlaygroundPopped)
        }

        let testingPlaygroundPoppedObservable = testingPlaygroundPopped
            .map { OWTestingPlaygroundCoordinatorResult.popped }
            .asObservable()

        return Observable.merge(
            testingPlaygroundPoppedObservable
        )
    }

    override func showableComponent() -> Observable<OWShowable> {
        // Add the View and VM you would like to test
//        let someViewVM: OWSomeViewViewModeling = ...
//        let someView = OWSomeView(viewModel: someViewVM)
        let someViewVM = OWTestingRxTableViewAnimationsViewViewModel()
        let someView = OWTestingRxTableViewAnimationsView(viewModel: someViewVM)

        return .just(someView)
    }
}

#endif
