//
//  CustomizationsViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import Combine
import OpenWebSDK

class CustomizationsViewModel: NSObject, ObservableObject {
    @SDKSetting(SettingsItems.sortOption) var selectedSortOption: SortOptionSetting
    @SDKSetting(SettingsItems.actionColor) var selectedActionColor: OWCommentActionsColor
    @SDKSetting(SettingsItems.actionFont) var selectedActionFont: OWCommentActionsFontStyle
    @SDKSetting(SettingsItems.fontFamily) var selectedFontFamily: FontFamilySetting
    @SDKSetting(SettingsItems.themeMode) var selectedThemeMode: ThemeModeSetting
    @SDKSetting(SettingsItems.enableCustomUICallback) var enableCustomUICallback: Bool
}

// MARK: - Setting Enums

extension CustomizationsViewModel {
    enum SortOptionSetting: Codable, CaseIterable, Identifiable {
        case server
        case best
        case newest
        case oldest

        var id: Self { self }
        var title: String {
            switch self {
            case .server: "Server"
            case .best: "Best"
            case .newest: "Newest"
            case .oldest: "Oldest"
            }
        }
    }

    enum FontFamilySetting: Codable, CaseIterable, Identifiable {
        case `default`
        case custom

        var id: Self { self }
        var title: String {
            switch self {
            case .default: "Default"
            case .custom: "Custom"
            }
        }
    }

    enum ThemeModeSetting: Codable, CaseIterable, Identifiable {
        case system
        case light
        case dark

        var id: Self { self }
        var title: String {
            switch self {
            case .system: "System Default"
            case .light: "Light"
            case .dark: "Dark"
            }
        }
    }
}
