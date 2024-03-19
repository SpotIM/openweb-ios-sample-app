//
//  NetworkSettingsVM.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 21/02/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

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

    fileprivate struct Metrics {
        static let delayInsertDataToPersistense = 100
    }

    fileprivate var userDefaultsProvider: UserDefaultsProviderProtocol
    fileprivate let disposeBag = DisposeBag()

    lazy var title: String = {
        return NSLocalizedString("NetworkSettings", comment: "")
    }()

    lazy var networkEnvironmentTitle: String = {
        return NSLocalizedString("NetworkEnvironment", comment: "")
    }()

    lazy var networkEnvironmentSettings: [String] = {
        let _prod = NSLocalizedString("Production", comment: "")
        let _staging = NSLocalizedString("Staging", comment: "")

        return [_prod, _staging]
    }()

    var networkEnvironmentSelectedIndex = BehaviorSubject<Int>(value: 0)

    var networkEnvironmentIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .networkEnvironment, defaultValue: OWNetworkEnvironment.production)
            .map { env in
                env.index
            }
            .asObservable()
    }

    fileprivate lazy var environmentObservable: Observable<OWNetworkEnvironment> = {
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

fileprivate extension NetworkSettingsVM {
    func setupObservers() {
        environmentObservable
            .throttle(.milliseconds(Metrics.delayInsertDataToPersistense), scheduler: MainScheduler.instance)
            .skip(1)
            .bind(to: self.userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<OWNetworkEnvironment>.networkEnvironment))
            .disposed(by: disposeBag)
    }
}

extension NetworkSettingsVM: SettingsGroupVMProtocol { }
