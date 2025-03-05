//
//  MainPageCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 07/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import Combine

class MainPageCoordinator: BaseCoordinator<Void> {

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> AnyPublisher<Void, Never> {
        let mainPageVM: MainPageViewModeling = MainPageViewModel()
        let mainPageVC = MainPageVC(viewModel: mainPageVM)
        router.setRoot(mainPageVC)

        // Define deep links variables
        let deepLinkAboutScreen = CurrentValueSubject<Void?, Never>(value: nil)
        var deepLinkToAbout: AnyPublisher<Void, Never> {
            return deepLinkAboutScreen
                .unwrap()
                .eraseToAnyPublisher()
        }

        let deepLinkTestAPIScreen = CurrentValueSubject<Void?, Never>(value: nil)
        var deepLinkToTestAPI: AnyPublisher<Void, Never> {
            return deepLinkTestAPIScreen
                .unwrap()
                .eraseToAnyPublisher()
        }

        // Define childs coordinators
        let aboutCoordinator = Publishers.MergeMany(mainPageVM.outputs.showAbout.eraseToAnyPublisher().map { nil },
                                                deepLinkToAbout.map { deepLinkOptions })
            .flatMap { [weak self] deepLink -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let coordinator = AboutCoordinator(router: self.router)
                return self.coordinate(to: coordinator, deepLinkOptions: deepLink)
            }

        let testAPICoordinator = Publishers.MergeMany(mainPageVM.outputs.testAPI.eraseToAnyPublisher().map { nil },
                                                  deepLinkToTestAPI.map { deepLinkOptions })
            .flatMap { [weak self] deepLink -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let coordinator = TestAPICoordinator(router: self.router)
                return self.coordinate(to: coordinator, deepLinkOptions: deepLink)
            }

        // Perfoem deep link if such
        if let deepLink = deepLinkOptions {
            switch deepLink {
            case .about:
                deepLinkAboutScreen.send(())
            case .testAPI, .settings, .authenticationPlayground:
                deepLinkTestAPIScreen.send(())
            }
        }

        return Publishers.Merge(aboutCoordinator, testAPICoordinator)
            .flatMap { _ -> AnyPublisher<Void, Never> in
                // We always showing the main demo screen, that's why we return never here.
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
