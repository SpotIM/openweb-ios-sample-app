//
//  AuthenticationPlaygroundCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 11/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

class AuthenticationPlaygroundCoordinator: BaseCoordinator<Void> {

    fileprivate let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil) -> Observable<Void> {
        let authenticationPlaygroundVM: AuthenticationPlaygroundViewModeling = AuthenticationPlaygroundViewModel()
        let authenticationPlaygroundVC = AuthenticationPlaygroundVC(viewModel: authenticationPlaygroundVM)

        let vcPopped = PublishSubject<Void>()

        var shouldAnimate = true
        if let deepLink = deepLinkOptions, deepLink == .authenticationPlayground {
            shouldAnimate = false
        }

        router.push(authenticationPlaygroundVC,
                    animated: shouldAnimate,
                    completion: vcPopped)

        return vcPopped
            .asObservable()
    }
}
