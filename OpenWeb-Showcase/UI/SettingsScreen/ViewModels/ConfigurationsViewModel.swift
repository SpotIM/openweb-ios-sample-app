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
    @Published var selectedLanguageStrategy: LanguageStrategySetting = .device
    @Published var selectedLanguage: SupportedLanguage = .english
    @Published var selectedLocaleStrategy: LocaleStrategySetting = .device
    @Published var enableLandscape: Bool = false

    var isCustomLanguageEnabled: Bool {
        selectedLanguageStrategy == .custom
    }
}

// MARK: - Setting Enums

extension ConfigurationsViewModel {
    enum LanguageStrategySetting: CaseIterable, Identifiable {
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

    enum SupportedLanguage: CaseIterable, Identifiable {
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

    enum LocaleStrategySetting: CaseIterable, Identifiable {
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
