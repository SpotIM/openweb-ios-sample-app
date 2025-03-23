//
//  SettingsCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 11/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import Combine

class SettingsCoordinator: BaseCoordinator<Void> {

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> AnyPublisher<Void, Never> {

        guard let data = coordinatorData,
              case CoordinatorData.settingsScreen(let settingsGroups) = data else {
            fatalError("SettingsCoordinator requires coordinatorData from `CoordinatorData.settingsScreen` type")
        }

        let settingsVM: SettingsViewModeling = SettingsViewModel(settingViewTypes: settingsGroups)
        let settingsVC = SettingsVC(viewModel: settingsVM)

        let vcPopped = PassthroughSubject<Void, Never>()

        var shouldAnimate = true
        if let deepLink = deepLinkOptions, deepLink == .settings {
            shouldAnimate = false
        }

        setupCoordinatorInternalNavigation(viewModel: settingsVM)

        router.push(settingsVC,
                    animated: shouldAnimate,
                    completion: vcPopped)

        return vcPopped
            .eraseToAnyPublisher()
    }
}

private extension SettingsCoordinator {
    func setupCoordinatorInternalNavigation(viewModel: SettingsViewModeling) {
        if let generalSettingsVM = viewModel.outputs.settingsVMs.first(where: { $0 is GeneralSettingsViewModeling }) as? GeneralSettingsViewModeling {
            generalSettingsVM.outputs.openColorsCustomizationScreen
                .sink(receiveValue: { [weak self] colorsCustomizationVC in
                    guard let self else { return }
                    self.router.push(colorsCustomizationVC,
                                     animated: true,
                                     completion: nil)
                })
                .store(in: &cancellables)
        }
    }
}
