//
//  NetworkSettingsVM.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 21/02/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import Combine
import OpenWebSDK

protocol NetworkSettingsViewModelingInputs {
    var networkEnvironmentSelected: CurrentValueSubject<OWNetworkEnvironment, Never> { get }
}

protocol NetworkSettingsViewModelingOutputs {
    var title: String { get }
    var networkEnvironmentTitle: String { get }
    var networkEnvironmentCustomTitle: String { get }
    var networkEnvironmentSettings: [String] { get }
    var networkEnvironment: AnyPublisher<OWNetworkEnvironment, Never> { get }
}

protocol NetworkSettingsViewModeling {
    var inputs: NetworkSettingsViewModelingInputs { get }
    var outputs: NetworkSettingsViewModelingOutputs { get }
}

class NetworkSettingsVM: NetworkSettingsViewModeling, NetworkSettingsViewModelingInputs, NetworkSettingsViewModelingOutputs {
    var inputs: NetworkSettingsViewModelingInputs { return self }
    var outputs: NetworkSettingsViewModelingOutputs { return self }

    private var userDefaultsProvider: UserDefaultsProviderProtocol
    private var cancellables = Set<AnyCancellable>()

    lazy var title: String = {
        return NSLocalizedString("NetworkSettings", comment: "")
    }()

    lazy var networkEnvironmentTitle: String = {
        return NSLocalizedString("NetworkEnvironment", comment: "")
    }()

    lazy var networkEnvironmentCustomTitle: String = {
        return NSLocalizedString("NetworkEnvironmentCustom", comment: "")
    }()

    lazy var networkEnvironmentSettings: [String] = {
        let _prod = NSLocalizedString("Production", comment: "")
        let _staging = NSLocalizedString("Staging", comment: "")
        let _cluster1d = NSLocalizedString("1DCluster", comment: "")

        return [_prod, _staging, _cluster1d]
    }()

    lazy var networkEnvironmentSelected = CurrentValueSubject<OWNetworkEnvironment, Never>(
        value: userDefaultsProvider.get(key: .networkEnvironment, defaultValue: OWNetworkEnvironment.default)
    )

    var networkEnvironment: AnyPublisher<OWNetworkEnvironment, Never> {
        return networkEnvironmentSelected
            .eraseToAnyPublisher()
    }

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

private extension NetworkSettingsVM {
    func setupObservers() {
        networkEnvironmentSelected
            .dropFirst()
            .bind(to: self.userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<OWNetworkEnvironment>.networkEnvironment))
            .store(in: &cancellables)
    }
}

extension NetworkSettingsVM: SettingsGroupVMProtocol {
    func resetToDefault() {
        networkEnvironmentSelected.send(OWNetworkEnvironment.default)
    }
}
