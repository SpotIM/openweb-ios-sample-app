//
//  ClarityDetailsSettingsVM.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 27/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

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

    fileprivate var userDefaultsProvider: UserDefaultsProviderProtocol
    fileprivate let disposeBag = DisposeBag()

    lazy var title: String = {
        return NSLocalizedString("ClarityDetailsSettings", comment: "")
    }()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

fileprivate extension ClarityDetailsSettingsVM {
    func setupObservers() {
    }
}

extension ClarityDetailsSettingsVM: SettingsGroupVMProtocol { }
