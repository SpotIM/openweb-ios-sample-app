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

class CustomizationsViewModel: ObservableObject {
    private let manager = SettingsManager.shared
    private var cancellables = Set<AnyCancellable>()

    @Published var selectedSortOption: SortOptionSetting = SettingsItems.sortOption.defaultValue
    @Published var selectedActionColor: ActionColorSetting = SettingsItems.actionColor.defaultValue
    @Published var selectedActionFont: ActionFontSetting = SettingsItems.actionFont.defaultValue
    @Published var selectedFontFamily: FontFamilySetting = SettingsItems.fontFamily.defaultValue
    @Published var selectedThemeMode: ThemeModeSetting = SettingsItems.themeMode.defaultValue
    @Published var customDarkColor: Color = Color(hex: SettingsItems.customDarkColor.defaultValue)
    @Published var enableCustomUIDelegation: Bool = SettingsItems.enableCustomUIDelegation.defaultValue

    init() {
        loadSettings()
        observeChanges()
    }

    func loadSettings() {
        selectedSortOption = manager.get(SettingsItems.sortOption)
        selectedActionColor = manager.get(SettingsItems.actionColor)
        selectedActionFont = manager.get(SettingsItems.actionFont)
        selectedFontFamily = manager.get(SettingsItems.fontFamily)
        selectedThemeMode = manager.get(SettingsItems.themeMode)
        customDarkColor = Color(hex: manager.get(SettingsItems.customDarkColor))
        enableCustomUIDelegation = manager.get(SettingsItems.enableCustomUIDelegation)
    }
}

// MARK: - Private

private extension CustomizationsViewModel {
    func observeChanges() {
        $selectedSortOption.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.sortOption, value: $0) }.store(in: &cancellables)
        $selectedActionColor.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.actionColor, value: $0) }.store(in: &cancellables)
        $selectedActionFont.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.actionFont, value: $0) }.store(in: &cancellables)
        $selectedFontFamily.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.fontFamily, value: $0) }.store(in: &cancellables)
        $selectedThemeMode.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.themeMode, value: $0) }.store(in: &cancellables)
        $customDarkColor.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.customDarkColor, value: $0.hexString) }.store(in: &cancellables)
        $enableCustomUIDelegation.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.enableCustomUIDelegation, value: $0) }.store(in: &cancellables)
    }
}

// MARK: - Setting Enums

extension CustomizationsViewModel {
    enum SortOptionSetting: Codable, CaseIterable, Identifiable, SDKApplicable {
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
