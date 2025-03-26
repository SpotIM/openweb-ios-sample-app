//
//  SampleAppSettingsVM.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 12/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import OpenWebSDK

protocol SampleAppSettingsViewModelingInputs {
    var deeplinkOptionSelected: BehaviorSubject<SampleAppDeeplink> { get }
    var callingMethodOptionSelected: BehaviorSubject<SampleAppCallingMethod> { get }
    var flowsLoggerEnable: BehaviorSubject<Bool> { get }
}

protocol SampleAppSettingsViewModelingOutputs {
    var title: String { get }
    var appDeeplinkTitle: String { get }
    var appDeeplinkSettings: [String] { get }
    var deeplinkOption: Observable<SampleAppDeeplink> { get }
    var callingMethodTitle: String { get }
    var callingMethodSettings: [String] { get }
    var callingMethodOption: Observable<SampleAppCallingMethod> { get }
    var flowsLoggerSwitchTitle: String { get }
    var flowsLoggerEnabled: Observable<Bool> { get }
}

protocol SampleAppSettingsViewModeling {
    var inputs: SampleAppSettingsViewModelingInputs { get }
    var outputs: SampleAppSettingsViewModelingOutputs { get }
}

class SampleAppSettingsVM: SampleAppSettingsViewModeling, SampleAppSettingsViewModelingInputs, SampleAppSettingsViewModelingOutputs {
    var inputs: SampleAppSettingsViewModelingInputs { return self }
    var outputs: SampleAppSettingsViewModelingOutputs { return self }

    var deeplinkOptionSelected = BehaviorSubject<SampleAppDeeplink>(value: SampleAppDeeplink.default)
    var deeplinkOption: Observable<SampleAppDeeplink> {
        return userDefaultsProvider.values(key: .deeplinkOption, defaultValue: SampleAppDeeplink.default)
    }

    var flowsLoggerEnable = BehaviorSubject<Bool>(value: false)
    var flowsLoggerEnabled: Observable<Bool> {
        return userDefaultsProvider.values(key: .flowsLoggerEnabled, defaultValue: false)
    }

    lazy var title: String = {
        return NSLocalizedString("SampleAppSettings", comment: "")
    }()

    lazy var appDeeplinkTitle: String = {
        return NSLocalizedString("Deeplink", comment: "")
    }()

    lazy var callingMethodTitle: String = {
        return NSLocalizedString("CallingMethod", comment: "")
    }()

    lazy var callingMethodSettings: [String] = {
        return SampleAppCallingMethod.allCases.map { $0.description }
    }()

    var callingMethodOptionSelected = BehaviorSubject<SampleAppCallingMethod>(value: .default)
    var callingMethodOption: Observable<SampleAppCallingMethod> {
        return userDefaultsProvider.values(key: .callingMethodOption, defaultValue: .default)
    }

    lazy var flowsLoggerSwitchTitle: String = {
        return NSLocalizedString("UIFlowsLogger", comment: "")
    }()

    lazy var appDeeplinkSettings: [String] = {
        let none = NSLocalizedString("None", comment: "")
        let about = NSLocalizedString("About", comment: "")
        let testAPI = NSLocalizedString("TestAPI", comment: "")
        let settings = NSLocalizedString("Settings", comment: "")
        let authentication = NSLocalizedString("Authentication", comment: "")

        return [none, about, testAPI, settings, authentication]
    }()

    private let disposeBag = DisposeBag()
    private var userDefaultsProvider: UserDefaultsProviderProtocol

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

private extension SampleAppSettingsVM {
    func setupObservers() {
        deeplinkOptionSelected
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
                .setValues(key: UserDefaultsProvider.UDKey<SampleAppDeeplink>.deeplinkOption))
            .disposed(by: disposeBag)

        callingMethodOptionSelected
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
                .setValues(key: UserDefaultsProvider.UDKey<SampleAppCallingMethod>.callingMethodOption))
            .disposed(by: disposeBag)

        flowsLoggerEnable
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
                .setValues(key: UserDefaultsProvider.UDKey<Bool>.flowsLoggerEnabled))
            .disposed(by: disposeBag)
    }
}

extension SampleAppSettingsVM: SettingsGroupVMProtocol {
    func resetToDefault() {
        deeplinkOptionSelected.onNext(SampleAppDeeplink.default)
        callingMethodOptionSelected.onNext(.default)
        flowsLoggerEnable.onNext(false)
    }
}
