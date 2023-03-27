//
//  IAUSettingsVM.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 28/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

#if NEW_API

protocol IAUSettingsViewModelingInputs {
}

protocol IAUSettingsViewModelingOutputs {
    var title: String { get }
}

protocol IAUSettingsViewModeling {
    var inputs: IAUSettingsViewModelingInputs { get }
    var outputs: IAUSettingsViewModelingOutputs { get }
}

class IAUSettingsVM: IAUSettingsViewModeling, IAUSettingsViewModelingInputs, IAUSettingsViewModelingOutputs {
    var inputs: IAUSettingsViewModelingInputs { return self }
    var outputs: IAUSettingsViewModelingOutputs { return self }

    fileprivate var userDefaultsProvider: UserDefaultsProviderProtocol

    fileprivate let disposeBag = DisposeBag()

    lazy var title: String = {
        return NSLocalizedString("IAUSettings", comment: "")
    }()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

extension IAUSettingsVM {
    func setupObservers() {
    }
}

extension IAUSettingsVM: SettingsGroupVMProtocol {

}
#endif
