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
    private let manager = SettingsManager.shared
    private var cancellables = Set<AnyCancellable>()

    @SDKSetting(SettingsItems.sortOption) var selectedSortOption: SortOptionSetting
    @SDKSetting(SettingsItems.actionColor) var selectedActionColor: ActionColorSetting
    @SDKSetting(SettingsItems.actionFont) var selectedActionFont: ActionFontSetting
    @SDKSetting(SettingsItems.fontFamily) var selectedFontFamily: FontFamilySetting
    @SDKSetting(SettingsItems.themeMode) var selectedThemeMode: ThemeModeSetting
    @Published var enableCustomUIDelegation: Bool = SettingsItems.enableCustomUIDelegation.defaultValue

    init() {
        loadSettings()
        observeChanges()
    }

    func loadSettings() {
        enableCustomUIDelegation = manager.get(SettingsItems.enableCustomUIDelegation)
    }
}

// MARK: - Private

private extension CustomizationsViewModel {
    func observeChanges() {
        $enableCustomUIDelegation.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.enableCustomUIDelegation, value: $0) }.store(in: &cancellables)
    }
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

    enum ActionColorSetting: Codable, CaseIterable, Identifiable {
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

    enum ActionFontSetting: Codable, CaseIterable, Identifiable {
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
