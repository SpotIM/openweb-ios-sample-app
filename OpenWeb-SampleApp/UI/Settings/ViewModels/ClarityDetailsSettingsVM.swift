//
//  ClarityDetailsSettingsVM.swift
//  OpenWeb-Development
//
//  Created by  Nogah Melamed on 27/09/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK

protocol ClarityDetailsSettingsViewModelingInputs {
}

protocol ClarityDetailsSettingsViewModelingOutputs {
}

protocol ClarityDetailsSettingsViewModeling {
    var inputs: ClarityDetailsSettingsViewModelingInputs { get }
    var outputs: ClarityDetailsSettingsViewModelingOutputs { get }
}

class ClarityDetailsSettingsVM: ClarityDetailsSettingsViewModeling, ClarityDetailsSettingsViewModelingInputs, ClarityDetailsSettingsViewModelingOutputs {
    var inputs: ClarityDetailsSettingsViewModelingInputs { return self }
    var outputs: ClarityDetailsSettingsViewModelingOutputs { return self }

    private var userDefaultsProvider: UserDefaultsProviderProtocol

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

private extension ClarityDetailsSettingsVM {
    func setupObservers() {
    }
}

extension ClarityDetailsSettingsVM: SettingsGroupVMProtocol {
    func resetToDefault() {
    }
}
