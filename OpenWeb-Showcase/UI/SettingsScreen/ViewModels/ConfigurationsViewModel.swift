//
//  ConfigurationsViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import Combine

class ConfigurationsViewModel: NSObject, ObservableObject {
    @SDKSetting(SettingsItems.languageStrategy) var selectedLanguageStrategy: LanguageStrategySetting
    @SDKSetting(SettingsItems.customLanguage) var selectedLanguage: SupportedLanguage
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

    enum SupportedLanguage: Codable, CaseIterable, Identifiable {
        case english
        case arabic
        case dutch
        case french
        case german
        case hebrew
        case hungarian
        case indonesian
        case italian
        case japanese
        case korean
        case portuguese
        case spanish
        case thai
        case turkish
        case vietnamese

        var id: Self { self }
        var title: String {
            switch self {
            case .english: "English"
            case .arabic: "Arabic"
            case .dutch: "Dutch"
            case .french: "French"
            case .german: "German"
            case .hebrew: "Hebrew"
            case .hungarian: "Hungarian"
            case .indonesian: "Indonesian"
            case .italian: "Italian"
            case .japanese: "Japanese"
            case .korean: "Korean"
            case .portuguese: "Portuguese"
            case .spanish: "Spanish"
            case .thai: "Thai"
            case .turkish: "Turkish"
            case .vietnamese: "Vietnamese"
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
