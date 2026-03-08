//
//  CustomizationsViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import Combine

class CustomizationsViewModel: ObservableObject {
    @Published var selectedSortOption: SortOptionSetting = .server
    @Published var selectedActionColor: ActionColorSetting = .default
    @Published var selectedActionFont: ActionFontSetting = .default
    @Published var selectedFontFamily: FontFamilySetting = .default
    @Published var selectedThemeMode: ThemeModeSetting = .system
    @Published var customDarkColor: Color = Color(hex: "#070707")
    @Published var enableCustomUIDelegation: Bool = false
}

// MARK: - Setting Enums

extension CustomizationsViewModel {
    enum SortOptionSetting: CaseIterable, Identifiable {
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

    enum ActionColorSetting: CaseIterable, Identifiable {
        case `default`
        case brandColor

        var id: Self { self }
        var title: String {
            switch self {
            case .default: "Default"
            case .brandColor: "Brand Color"
            }
        }
    }

    enum ActionFontSetting: CaseIterable, Identifiable {
        case `default`
        case semiBold

        var id: Self { self }
        var title: String {
            switch self {
            case .default: "Default"
            case .semiBold: "Semi Bold"
            }
        }
    }

    enum FontFamilySetting: CaseIterable, Identifiable {
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

    enum ThemeModeSetting: CaseIterable, Identifiable {
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
