//
//  ConfigurationsViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import Combine

class ConfigurationsViewModel: ObservableObject {
    private let manager = SettingsManager.shared
    private var cancellables = Set<AnyCancellable>()

    @SDKSetting(SettingsItems.languageStrategy) var selectedLanguageStrategy: LanguageStrategySetting
    @SDKSetting(SettingsItems.customLanguage) var selectedLanguage: SupportedLanguage
    @SDKSetting(SettingsItems.localeStrategy) var selectedLocaleStrategy: LocaleStrategySetting
    @Published var enableLandscape: Bool = SettingsItems.enableLandscape.defaultValue

    var isCustomLanguageEnabled: Bool {
        selectedLanguageStrategy == .custom
    }

    init() {
        loadSettings()
        observeChanges()
    }

    func loadSettings() {
        enableLandscape = manager.get(SettingsItems.enableLandscape)
    }
}

// MARK: - Private

private extension ConfigurationsViewModel {
    func observeChanges() {
        $enableLandscape.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.enableLandscape, value: $0) }.store(in: &cancellables)
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
