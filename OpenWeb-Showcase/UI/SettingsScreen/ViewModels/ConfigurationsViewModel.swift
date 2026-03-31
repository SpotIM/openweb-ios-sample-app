//
//  ConfigurationsViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import Combine
import OpenWebSDK

class ConfigurationsViewModel: NSObject, ObservableObject {
    @SDKSetting(SettingsItems.languageStrategy) var selectedLanguageStrategy: LanguageStrategySetting
    @SDKSetting(SettingsItems.customLanguage) var selectedLanguage: OWSupportedLanguage
    @SDKSetting(SettingsItems.localeStrategy) var selectedLocaleStrategy: LocaleStrategySetting
    @SDKSetting(SettingsItems.enableLandscape) var enableLandscape: EnableLandscapeSetting

    var isCustomLanguageEnabled: Bool {
        selectedLanguageStrategy == .custom
    }

    var enableLandscapeBinding: Binding<Bool> {
        Binding(
            get: { [weak self] in self?.enableLandscape == .enabled },
            set: { [weak self] in self?.enableLandscape = $0 ? .enabled : .disabled }
        )
    }
}

// MARK: - Setting Enums

extension ConfigurationsViewModel {
    enum LanguageStrategySetting: Codable, CaseIterable, Identifiable {
        case device
        case server
        case custom

        var id: Self { self }
        var title: String {
            switch self {
            case .device: "Device"
            case .server: "Server"
            case .custom: "Custom"
            }
        }
    }

    enum EnableLandscapeSetting: Codable, CaseIterable, Identifiable {
        case disabled
        case enabled

        var id: Self { self }
    }

    enum LocaleStrategySetting: Codable, CaseIterable, Identifiable {
        case device
        case server

        var id: Self { self }
        var title: String {
            switch self {
            case .device: "Device"
            case .server: "Server"
            }
        }
    }
}
