//
//  SettingsViewModel.swift
//  OpenWeb-Development
//
//  Created by Revital Pisman on 18/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import Combine
import OpenWebSDK

protocol SettingsViewModelingInputs {
    var resetToDefaultTap: PassthroughSubject<Void, Never> { get }
}

protocol SettingsViewModelingOutputs {
    var title: String { get }
    var settingsVMs: [SettingsGroupVMProtocol] { get }
}

protocol SettingsViewModeling {
    var inputs: SettingsViewModelingInputs { get }
    var outputs: SettingsViewModelingOutputs { get }
}

class SettingsViewModel: SettingsViewModeling, SettingsViewModelingInputs, SettingsViewModelingOutputs {
    var inputs: SettingsViewModelingInputs { return self }
    var outputs: SettingsViewModelingOutputs { return self }
    private var settingViewTypes: [SettingsGroupType]
    private var userDefaultsProvider: UserDefaultsProviderProtocol
    private var manager: OWManagerProtocol

    lazy var settingsVMs: [SettingsGroupVMProtocol] = {
        let settingsVMs: [SettingsGroupVMProtocol] = settingViewTypes.map { [weak self] type in
            guard let self else { return nil }
            return type.createAppropriateVM(userDefaultsProvider: self.userDefaultsProvider, manager: self.manager)
        }.unwrap()
        return settingsVMs
    }()

    private var cancellables = Set<AnyCancellable>()

    lazy var title: String = {
        return NSLocalizedString("Settings", comment: "")
    }()

    var resetToDefaultTap = PassthroughSubject<Void, Never>()

    init(settingViewTypes: [SettingsGroupType] = SettingsGroupType.all, userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared,
         manager: OWManagerProtocol = OpenWeb.manager) {
        self.settingViewTypes = settingViewTypes
        self.userDefaultsProvider = userDefaultsProvider
        self.manager = manager

        setupObservers()
    }
}

private extension SettingsViewModel {
    func setupObservers() {
        resetToDefaultTap
            .sink { [weak self] in
                guard let self else { return }
                self.settingsVMs.forEach { $0.resetToDefault() }
            }
            .store(in: &cancellables)
    }
}
