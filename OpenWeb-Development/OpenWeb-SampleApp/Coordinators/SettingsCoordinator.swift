//
//  SettingsCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 11/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

class SettingsCoordinator: BaseCoordinator<Void> {

    fileprivate let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> Observable<Void> {
        let settingsVM: SettingsViewModeling = SettingsViewModel(settingViewTypes: SettingsGroupType.all)
        let settingsVC = SettingsVC(viewModel: settingsVM)

        let vcPopped = PublishSubject<Void>()

        var shouldAnimate = true
        if let deepLink = deepLinkOptions, deepLink == .settings {
            shouldAnimate = false
        }

        router.push(settingsVC,
                    animated: shouldAnimate,
                    completion: vcPopped)

        return vcPopped
            .asObservable()
    }
}
