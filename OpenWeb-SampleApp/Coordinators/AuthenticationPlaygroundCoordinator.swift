//
//  AuthenticationPlaygroundCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 11/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Combine
import OpenWebSDK

class AuthenticationPlaygroundCoordinator: BaseCoordinator<Void> {

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> AnyPublisher<Void, Never> {
        let authenticationPlaygroundVM: AuthenticationPlaygroundViewModeling = AuthenticationPlaygroundViewModel(filterBySpotId: OpenWeb.manager.spotId)
        let authenticationPlaygroundVC = AuthenticationPlaygroundVC(viewModel: authenticationPlaygroundVM)

        let vcPopped = PassthroughSubject<Void, Never>()

        var shouldAnimate = true
        if let deepLink = deepLinkOptions, deepLink == .authenticationPlayground {
            shouldAnimate = false
        }

        router.push(authenticationPlaygroundVC,
                    animated: shouldAnimate,
                    completion: vcPopped)

        return vcPopped
            .eraseToAnyPublisher()
    }
}
