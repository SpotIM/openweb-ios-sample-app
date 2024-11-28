//
//  OWFontsCoordinator.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 25/10/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift

#if AUTOMATION

/*
 This coordinator file will compile only under `AUTOMATION` flag.
 */

enum OWFontsCoordinatorResult: OWCoordinatorResultProtocol {
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

class OWFontsCoordinator: OWBaseCoordinator<OWFontsCoordinatorResult> {

    // Router is being used only for `Flows` mode. Intentionally defined as force unwrap for easy access.
    // Trying to use that in `Standalone Views` mode will cause a crash immediately.
    private let router: OWRoutering!
    private let automationData: OWAutomationRequiredData

    init(router: OWRoutering! = nil, automationData: OWAutomationRequiredData) {
        self.router = router
        self.automationData = automationData
    }

    override func start(coordinatorData: OWCoordinatorData? = nil) -> Observable<OWFontsCoordinatorResult> {

        let fontsVM = OWFontsAutomationViewModel()
        let fontsVC = OWFontsAutomationVC(viewModel: fontsVM)

        let fontsPopped = PublishSubject<Void>()

        // Testing playground is the initial view in the router so here we start the router
        router.start()

        if router.isEmpty() {
            router.setRoot(fontsVC, animated: false, dismissCompletion: fontsPopped)
        } else {
            router.push(fontsVC,
                        pushStyle: .regular,
                        animated: true,
                        popCompletion: fontsPopped)
        }

        let fontsPoppedObservable = fontsPopped
            .map { OWFontsCoordinatorResult.popped }
            .asObservable()

        return Observable.merge(
            fontsPoppedObservable
        )
    }

    override func showableComponent() -> Observable<OWShowable> {
        let fontsViewVM = OWFontsAutomationViewViewModel()
        let fontsView = OWFontsAutomationView(viewModel: fontsViewVM)

        return .just(fontsView)
    }
}

#endif
