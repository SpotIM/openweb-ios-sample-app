//
//  SampleAppSettingsVM.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 12/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import Combine
import OpenWebSDK

protocol SampleAppSettingsViewModelingInputs {
    var deeplinkOptionSelected: CurrentValueSubject<SampleAppDeeplink, Never> { get }
    var callingMethodOptionSelected: CurrentValueSubject<SampleAppCallingMethod, Never> { get }
    var flowsLoggerEnable: CurrentValueSubject<Bool, Never> { get }
}

protocol SampleAppSettingsViewModelingOutputs {
    var title: String { get }
    var appDeeplinkTitle: String { get }
    var appDeeplinkSettings: [String] { get }
    var deeplinkOption: AnyPublisher<SampleAppDeeplink, Never> { get }
    var callingMethodTitle: String { get }
    var callingMethodSettings: [String] { get }
    var callingMethodOption: AnyPublisher<SampleAppCallingMethod, Never> { get }
    var flowsLoggerSwitchTitle: String { get }
    var flowsLoggerEnabled: AnyPublisher<Bool, Never> { get }
}

protocol SampleAppSettingsViewModeling {
    var inputs: SampleAppSettingsViewModelingInputs { get }
    var outputs: SampleAppSettingsViewModelingOutputs { get }
}

class SampleAppSettingsVM: SampleAppSettingsViewModeling, SampleAppSettingsViewModelingInputs, SampleAppSettingsViewModelingOutputs {
    var inputs: SampleAppSettingsViewModelingInputs { return self }
    var outputs: SampleAppSettingsViewModelingOutputs { return self }

    lazy var deeplinkOptionSelected = CurrentValueSubject<SampleAppDeeplink, Never>(userDefaultsProvider.get(key: .deeplinkOption, defaultValue: SampleAppDeeplink.default))

    var deeplinkOption: AnyPublisher<SampleAppDeeplink, Never> {
        return deeplinkOptionSelected
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    lazy var flowsLoggerEnable = CurrentValueSubject<Bool, Never>(userDefaultsProvider.get(key: .flowsLoggerEnabled, defaultValue: false))

    var flowsLoggerEnabled: AnyPublisher<Bool, Never> {
        return flowsLoggerEnable
            .removeDuplicates()
            .eraseToAnyPublisher()
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

    lazy var callingMethodOptionSelected = CurrentValueSubject<SampleAppCallingMethod, Never>(userDefaultsProvider.get(key: .callingMethodOption, defaultValue: .default))

    var callingMethodOption: AnyPublisher<SampleAppCallingMethod, Never> {
        return callingMethodOptionSelected
            .removeDuplicates()
            .eraseToAnyPublisher()
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

    private var cancellables = Set<AnyCancellable>()
    private var userDefaultsProvider: UserDefaultsProviderProtocol

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

private extension SampleAppSettingsVM {
    func setupObservers() {
        deeplinkOptionSelected
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<SampleAppDeeplink>.deeplinkOption))
            .store(in: &cancellables)

        callingMethodOptionSelected
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<SampleAppCallingMethod>.callingMethodOption))
            .store(in: &cancellables)

        flowsLoggerEnable
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<Bool>.flowsLoggerEnabled))
            .store(in: &cancellables)
    }
}

extension SampleAppSettingsVM: SettingsGroupVMProtocol {
    func resetToDefault() {
        deeplinkOptionSelected.send(SampleAppDeeplink.default)
        callingMethodOptionSelected.send(.default)
        flowsLoggerEnable.send(false)
    }
}
