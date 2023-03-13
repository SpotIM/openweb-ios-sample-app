//
//  SettingsViewModel.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 18/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

#if NEW_API

protocol SettingsViewModelingInputs {

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
    fileprivate var settingViewTypes: [SettingsGroupType]
    fileprivate var userDefaultsProvider: UserDefaultsProviderProtocol
    fileprivate var manager: OWManagerProtocol

    lazy var settingsVMs: [SettingsGroupVMProtocol] = {
        let settingsVMs: [SettingsGroupVMProtocol] = settingViewTypes.map { [weak self] type in
            guard let self = self else { return nil }
            return type.createAppropriateVM(userDefaultsProvider: self.userDefaultsProvider, manager: self.manager)
        }.unwrap()
        return settingsVMs
    }()

    fileprivate let disposeBag = DisposeBag()

    lazy var title: String = {
        return NSLocalizedString("Settings", comment: "")
    }()

    init(settingViewTypes: [SettingsGroupType] = SettingsGroupType.all, userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared,
         manager: OWManagerProtocol = OpenWeb.manager) {
        self.settingViewTypes = settingViewTypes
        self.userDefaultsProvider = userDefaultsProvider
        self.manager = manager
    }
}

#endif
