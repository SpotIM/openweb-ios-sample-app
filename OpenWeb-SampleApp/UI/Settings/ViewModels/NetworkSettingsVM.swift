//
//  NetworkSettingsVM.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 21/02/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
import OpenWebSDK

protocol NetworkSettingsViewModelingInputs {
    var networkEnvironmentSelected: BehaviorSubject<OWNetworkEnvironment> { get }
}

protocol NetworkSettingsViewModelingOutputs {
    var title: String { get }
    var networkEnvironmentTitle: String { get }
    var networkEnvironmentCustomTitle: String { get }
    var networkEnvironmentSettings: [String] { get }
    var networkEnvironment: Observable<OWNetworkEnvironment> { get }
}

protocol NetworkSettingsViewModeling {
    var inputs: NetworkSettingsViewModelingInputs { get }
    var outputs: NetworkSettingsViewModelingOutputs { get }
}

class NetworkSettingsVM: NetworkSettingsViewModeling, NetworkSettingsViewModelingInputs, NetworkSettingsViewModelingOutputs {
    var inputs: NetworkSettingsViewModelingInputs { return self }
    var outputs: NetworkSettingsViewModelingOutputs { return self }

    private struct Metrics {
        static let delayInsertDataToPersistense = 100
    }

    private var userDefaultsProvider: UserDefaultsProviderProtocol
    private let disposeBag = DisposeBag()

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
        let _custom = NSLocalizedString("Custom", comment: "")

        return [_prod, _staging, _cluster1d, _custom]
    }()

    var networkEnvironmentSelected = BehaviorSubject<OWNetworkEnvironment>(value: OWNetworkEnvironment.default)

    var networkEnvironment: Observable<OWNetworkEnvironment> {
        return userDefaultsProvider.values(key: .networkEnvironment, defaultValue: OWNetworkEnvironment.production)
            .asObservable()
    }

    private lazy var environmentObservable: Observable<OWNetworkEnvironment> = {
        return networkEnvironmentSelected
            .asObservable()
    }()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

private extension NetworkSettingsVM {
    func setupObservers() {
        environmentObservable
            .throttle(.milliseconds(Metrics.delayInsertDataToPersistense), scheduler: MainScheduler.instance)
            .skip(1)
            .bind(to: self.userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<OWNetworkEnvironment>.networkEnvironment))
            .disposed(by: disposeBag)
    }
}

extension NetworkSettingsVM: SettingsGroupVMProtocol {
    func resetToDefault() {
        networkEnvironmentSelected.onNext(OWNetworkEnvironment.default)
    }
}
