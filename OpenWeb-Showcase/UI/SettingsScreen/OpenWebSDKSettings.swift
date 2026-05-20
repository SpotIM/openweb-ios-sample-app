//
//  OpenWebSDKSettings.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 17/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import OpenWebSDK

extension CustomizationsViewModel.SortOptionSetting: OpenWebApplicable {
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

extension OWCommentActionsColor: @retroactive CaseIterable, @retroactive Identifiable, OpenWebApplicable {
    public static var allCases: [OWCommentActionsColor] { [.default, .brandColor] }
    public var id: Self { self }
    var title: String {
        switch self {
        case .default: "Default"
        case .brandColor: "Brand Color"
        @unknown default: "Unknown"
        }
    }
    func applyToSDK() {
        // MARK: OpenWeb SDK
        OpenWeb.manager.ui.customizations.commentActions.color = self
    }
}

extension OWCommentActionsFontStyle: @retroactive CaseIterable, @retroactive Identifiable, OpenWebApplicable {
    public static var allCases: [OWCommentActionsFontStyle] { [.default, .semiBold] }
    public var id: Self { self }
    var title: String {
        switch self {
        case .default: "Default"
        case .semiBold: "Semi Bold"
        @unknown default: "Unknown"
        }
    }
    func applyToSDK() {
        // MARK: OpenWeb SDK
        OpenWeb.manager.ui.customizations.commentActions.fontStyle = self
    }
}

extension OWFontGroupFamily: OpenWebApplicable {
    func applyToSDK() {
        // MARK: OpenWeb SDK
        OpenWeb.manager.ui.customizations.fontFamily = self
    }
}

extension CustomizationsViewModel.ThemeModeSetting: OpenWebApplicable {
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

extension OWTheme: OpenWebApplicable {
    func applyToSDK() {
        // MARK: OpenWeb SDK
        OpenWeb.manager.ui.customizations.customizedTheme = self
    }
}

extension ConfigurationsViewModel.EnableLandscapeSetting: OpenWebApplicable {
    func applyToSDK() {
        let enforcement: OWOrientationEnforcement = switch self {
        case .enabled: .enableAll
        case .disabled: .enable(orientations: [.portrait])
        }

        // MARK: OpenWeb SDK
        OpenWeb.manager.helpers.orientationEnforcement = enforcement
    }
}

extension ConfigurationsViewModel.LocaleStrategySetting: OpenWebApplicable {
    func applyToSDK() {
        let strategy: OWLocaleStrategy = switch self {
        case .device: .useDevice
        case .server: .useServerConfig
        }

        // MARK: OpenWeb SDK
        OpenWeb.manager.helpers.localeStrategy = strategy
    }
}

extension ConfigurationsViewModel.LanguageStrategySetting: OpenWebApplicable {
    func applyToSDK() {
        let strategy: OWLanguageStrategy = switch self {
        case .device: .useDevice
        case .server: .useServerConfig
        case .custom:
            .use(language: SDKSetting(SettingsItems.customLanguage).wrappedValue)
        }

        // MARK: OpenWeb SDK
        OpenWeb.manager.helpers.languageStrategy = strategy
    }
}

extension OWSupportedLanguage: @retroactive Identifiable, OpenWebApplicable {
    public var id: Self { self }

    func applyToSDK() {
        guard SDKSetting(SettingsItems.languageStrategy).wrappedValue == .custom else { return }

        // MARK: OpenWeb SDK
        OpenWeb.manager.helpers.languageStrategy = .use(language: self)
    }

    static let showcaseLanguages: [OWSupportedLanguage] = allCases.filter {
        $0 != .portugueseBrazil && $0 != .portuguesePortugal
    }

    var displayName: String {
        Locale.current.localizedString(forLanguageCode: rawValue) ?? rawValue
    }
}

// MARK: - Types without SDK application

extension ArticleSettingsViewModel.InformationStrategySetting: OpenWebApplicable {}
extension String: OpenWebApplicable {}
extension Bool: OpenWebApplicable {}
extension Int: OpenWebApplicable {}
extension Double: OpenWebApplicable {}
extension ScreenSettingsViewModel.PreConversationStyleSetting: OpenWebApplicable {}
extension ScreenSettingsViewModel.ConversationStyleSetting: OpenWebApplicable {}
extension ScreenSettingsViewModel.ConversationSpacingSetting: OpenWebApplicable {}

extension OWCommunityGuidelinesStyle: @retroactive CaseIterable, @retroactive Identifiable, OpenWebApplicable {
    public static var allCases: [OWCommunityGuidelinesStyle] { [.none, .regular, .compact] }
    public var id: Self { self }
    var title: String {
        switch self {
        case .none: "None"
        case .regular: "Regular"
        case .compact: "Compact"
        @unknown default: "Unknown"
        }
    }
}

extension OWCommunityQuestionStyle: @retroactive CaseIterable, @retroactive Identifiable, OpenWebApplicable {
    public static var allCases: [OWCommunityQuestionStyle] { [.none, .regular, .compact] }
    public var id: Self { self }
    var title: String {
        switch self {
        case .none: "None"
        case .regular: "Regular"
        case .compact: "Compact"
        @unknown default: "Unknown"
        }
    }
}

extension OWReadOnlyMode: @retroactive CaseIterable, @retroactive Identifiable, @retroactive Codable, OpenWebApplicable {
    public static var allCases: [OWReadOnlyMode] { [.server, .enable, .disable] }
    public var id: Self { self }

    private var rawValue: String {
        switch self {
        case .server: "server"
        case .enable: "enable"
        case .disable: "disable"
        @unknown default: "server"
        }
    }

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case "enable": self = .enable
        case "disable": self = .disable
        default: self = .server
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    var title: String {
        switch self {
        case .server: "Server"
        case .enable: "Enable"
        case .disable: "Disable"
        @unknown default: "Unknown"
        }
    }
}
