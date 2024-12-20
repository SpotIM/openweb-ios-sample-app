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
    var networkEnvironmentSelectedIndex: BehaviorSubject<Int> { get }
}

protocol NetworkSettingsViewModelingOutputs {
    var title: String { get }
    var networkEnvironmentTitle: String { get }
    var networkEnvironmentSettings: [String] { get }
    var networkEnvironmentIndex: Observable<Int> { get }
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

    lazy var networkEnvironmentSettings: [String] = {
        let _prod = NSLocalizedString("Production", comment: "")
        let _staging = NSLocalizedString("Staging", comment: "")
        let _cluster1d = NSLocalizedString("1DCluster", comment: "")

        return [_prod, _staging, _cluster1d]
    }()

    var networkEnvironmentSelectedIndex = BehaviorSubject<Int>(value: OWNetworkEnvironment.default.index)

    var networkEnvironmentIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .networkEnvironment, defaultValue: OWNetworkEnvironment.production)
            .map { env in
                env.index
            }
            .asObservable()
    }

    private lazy var environmentObservable: Observable<OWNetworkEnvironment> = {
        return networkEnvironmentSelectedIndex
            .map {
                OWNetworkEnvironment(from: $0)
            }
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
        networkEnvironmentSelectedIndex.onNext(OWNetworkEnvironment.default.index)
    }
}
