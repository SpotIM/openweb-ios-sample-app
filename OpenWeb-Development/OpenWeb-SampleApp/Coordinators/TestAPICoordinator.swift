//
//  TestAPICoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 07/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

class TestAPICoordinator: BaseCoordinator<Void> {

    fileprivate let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil) -> Observable<Void> {
        let testAPIVM: TestAPIViewModeling = TestAPIViewModel()
        let testAPIVC = TestAPIVC(viewModel: testAPIVM)

        let vcPopped = PublishSubject<Void>()

        var shouldAnimate = true
        if let deepLink = deepLinkOptions,
           deepLink == .testAPI || deepLink == .settings {
            shouldAnimate = false
        }

        router.push(testAPIVC,
                    animated: shouldAnimate,
                    completion: vcPopped)

        // Define deep links variables
        let deepLinkSettingsScreen = BehaviorSubject<Void?>(value: nil)
        var deepLinkToSettings: Observable<Void> {
            return deepLinkSettingsScreen
                .unwrap()
                .asObservable()
        }

        // Define childs coordinators
        let settingsCoordinator = Observable.merge(testAPIVM.outputs.openSettings.map { nil },
                                                deepLinkToSettings.map { deepLinkOptions})
            .flatMap { [weak self] deepLink -> Observable<Void> in
                guard let self = self else { return .empty() }
                let coordinator = SettingsCoordinator(router: self.router)
                return self.coordinate(to: coordinator, deepLinkOptions: deepLink)
            }
            .flatMap { _ -> Observable<Void> in
                return .never()
            }

        // Perfoem deep link if such
        if let deepLink = deepLinkOptions {
            switch deepLink {
            case .settings:
                deepLinkSettingsScreen.onNext(())
            default:
                break
            }
        }

        return Observable.merge(vcPopped.asObservable(), settingsCoordinator)
    }
}
