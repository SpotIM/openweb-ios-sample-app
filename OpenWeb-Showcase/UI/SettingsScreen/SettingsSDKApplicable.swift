//
//  SettingsSDKApplicable.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 17/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import OpenWebSDK

// MARK: - SDKApplicable

extension CustomizationsViewModel.SortOptionSetting: SDKApplicable {
    func applyToSDK() {
        let strategy: OWInitialSortStrategy = switch self {
        case .server: .useServerConfig
        case .best: .use(sortOption: .best)
        case .newest: .use(sortOption: .newest)
        case .oldest: .use(sortOption: .oldest)
        }

        // MARK: OpenWeb SDK
        OpenWeb.manager.ui.customizations.sorting.initialOption = strategy
    }
}

extension CustomizationsViewModel.ActionColorSetting: SDKApplicable {
    func applyToSDK() {
        let color: OWCommentActionsColor = switch self {
        case .default: .default
        case .brandColor: .brandColor
        }

        // MARK: OpenWeb SDK
        OpenWeb.manager.ui.customizations.commentActions.color = color
    }
}

extension CustomizationsViewModel.ActionFontSetting: SDKApplicable {
    func applyToSDK() {
        let fontStyle: OWCommentActionsFontStyle = switch self {
        case .default: .default
        case .semiBold: .semiBold
        }

        // MARK: OpenWeb SDK
        OpenWeb.manager.ui.customizations.commentActions.fontStyle = fontStyle
    }
}

extension CustomizationsViewModel.FontFamilySetting: SDKApplicable {
    func applyToSDK() {
        let fontFamily: OWFontGroupFamily = switch self {
        case .default: .default
        case .custom: .custom(fontFamily: "Georgia")
        }

        // MARK: OpenWeb SDK
        OpenWeb.manager.ui.customizations.fontFamily = fontFamily
    }
}

extension CustomizationsViewModel.ThemeModeSetting: SDKApplicable {
    func applyToSDK() {
        let enforcement: OWThemeStyleEnforcement = switch self {
        case .system: .none
        case .light: .theme(.light)
        case .dark: .theme(.dark)
        }

        // MARK: OpenWeb SDK
        OpenWeb.manager.ui.customizations.themeEnforcement = enforcement
    }
}

extension ArticleSettingsViewModel.InformationStrategySetting: SDKApplicable {
    func applyToSDK() {}
}

extension String: SDKApplicable {
    func applyToSDK() {}
}

extension Bool: SDKApplicable {
    func applyToSDK() {}
}

extension ArticleSettingsViewModel.ReadOnlyModeSetting: SDKApplicable {
    func applyToSDK() {}
    var owMode: OWReadOnlyMode {
        switch self {
        case .server: .server
        case .enable: .enable
        case .disable: .disable
        }
    }
}

extension ConfigurationsViewModel.EnableLandscapeSetting: SDKApplicable {
    func applyToSDK() {
        let enforcement: OWOrientationEnforcement = switch self {
        case .enabled: .enableAll
        case .disabled: .enable(orientations: [.portrait])
        }

        // MARK: OpenWeb SDK
        OpenWeb.manager.helpers.orientationEnforcement = enforcement
    }
}

extension ConfigurationsViewModel.LocaleStrategySetting: SDKApplicable {
    func applyToSDK() {
        let strategy: OWLocaleStrategy = switch self {
        case .device: .useDevice
        case .server: .useServerConfig
        }

        // MARK: OpenWeb SDK
        OpenWeb.manager.helpers.localeStrategy = strategy
    }
}

extension ConfigurationsViewModel.LanguageStrategySetting: SDKApplicable {
    func applyToSDK() {
        let strategy: OWLanguageStrategy = switch self {
        case .device: .useDevice
        case .server: .useServerConfig
        case .custom:
            .use(language: SettingsManager.shared.get(SettingsItems.customLanguage).owLanguage)
        }

        // MARK: OpenWeb SDK
        OpenWeb.manager.helpers.languageStrategy = strategy
    }
}

extension ConfigurationsViewModel.SupportedLanguage: SDKApplicable {
    func applyToSDK() {
        guard SettingsManager.shared.get(SettingsItems.languageStrategy) == .custom else { return }

        // MARK: OpenWeb SDK
        OpenWeb.manager.helpers.languageStrategy = .use(language: owLanguage)
    }

    var owLanguage: OWSupportedLanguage {
        switch self {
        case .english: .english
        case .arabic: .arabic
        case .dutch: .dutch
        case .french: .french
        case .german: .german
        case .hebrew: .hebrew
        case .hungarian: .hungarian
        case .indonesian: .indonesian
        case .italian: .italian
        case .japanese: .japanese
        case .korean: .korean
        case .portuguese: .portugueseOther
        case .spanish: .spanish
        case .thai: .thai
        case .turkish: .turkish
        case .vietnamese: .vietnamese
        }
    }
}
