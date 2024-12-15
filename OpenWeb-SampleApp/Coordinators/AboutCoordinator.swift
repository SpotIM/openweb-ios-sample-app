//
//  AboutCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 07/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

class AboutCoordinator: BaseCoordinator<Void> {

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> Observable<Void> {
        let aboutVM: AboutViewModeling = AboutViewModel()
        let aboutVC = AboutVC(viewModel: aboutVM)

        var shouldAnimate = true
        if let deepLink = deepLinkOptions, deepLink == .about {
            shouldAnimate = false
        }

        let vcPopped = PublishSubject<Void>()

        router.push(aboutVC,
                    animated: shouldAnimate,
                    completion: vcPopped)

        return vcPopped
            .asObservable()
    }
}
