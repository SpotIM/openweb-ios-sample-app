//
//  MainPageCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 07/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

class MainPageCoordinator: BaseCoordinator<Void> {

    fileprivate let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil) -> Observable<Void> {
        let mainPageVM: MainPageViewModeling = MainPageViewModel()
        let mainPageVC = MainPageVC(viewModel: mainPageVM)
        router.setRoot(mainPageVC)

        // Define deep links variables
        let deepLinkAboutScreen = BehaviorSubject<Void?>(value: nil)
        var deepLinkToAbout: Observable<Void> {
            return deepLinkAboutScreen
                .unwrap()
                .asObservable()
        }

        let deepLinkTestAPIScreen = BehaviorSubject<Void?>(value: nil)
        var deepLinkToTestAPI: Observable<Void> {
            return deepLinkTestAPIScreen
                .unwrap()
                .asObservable()
        }

        // Define childs coordinators
        let aboutCoordinator = Observable.merge(mainPageVM.outputs.showAbout.map { nil },
                                                deepLinkToAbout.map { deepLinkOptions})
            .flatMap { [weak self] deepLink -> Observable<Void> in
                guard let self = self else { return .empty() }
                let coordinator = AboutCoordinator(router: self.router)
                return self.coordinate(to: coordinator, deepLinkOptions: deepLink)
            }

        let testAPICoordinator = Observable.merge(mainPageVM.outputs.testAPI.map { nil },
                                                  deepLinkToTestAPI.map { deepLinkOptions})
            .flatMap { [weak self] deepLink -> Observable<Void> in
                guard let self = self else { return .empty() }
                let coordinator = TestAPICoordinator(router: self.router)
                return self.coordinate(to: coordinator, deepLinkOptions: deepLink)
            }

        // Perfoem deep link if such
        if let deepLink = deepLinkOptions {
            switch deepLink {
            case .about:
                deepLinkAboutScreen.onNext(())
            case .testAPI, .settings, .authenticationPlayground:
                deepLinkTestAPIScreen.onNext(())
            }
        }

        return Observable.merge(aboutCoordinator, testAPICoordinator)
            .flatMap { _ -> Observable<Void> in
                // We always showing the main demo screen, that's why we return never here.
                return .never()
            }
    }
}
