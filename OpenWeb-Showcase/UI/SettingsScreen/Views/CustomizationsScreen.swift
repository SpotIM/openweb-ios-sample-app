//
//  CustomizationsScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import OpenWebSDK

struct CustomizationsScreen: View {
    @StateObject private var viewModel = CustomizationsViewModel()
    var highlightedEntryID: String?

    var body: some View {
        List {
            sortingSection
            fontsAndColorsSection
            uiCallbackSection
        }
        .scrollAndHighlight(entryID: highlightedEntryID)
        .navigationTitle(.customizationsScreenTitle)
        .settingsToolbar()
    }
}

// MARK: - Sections

private extension CustomizationsScreen {
    var sortingSection: some View {
        Section(.customizationsSortingSectionTitle) {
            SegmentedPickerRow(
                title: .customizationsSortOptionTitle,
                subtitle: .customizationsSortOptionSubtitle,
                selection: $viewModel.selectedSortOption,
                optionTitle: \.title
            )
            .settingsRow(SettingsItems.sortOption.key)
        }
    }

    var fontsAndColorsSection: some View {
        Section(.customizationsElementsSectionTitle) {
            SegmentedPickerRow(
                title: .customizationsThemeModeTitle,
                subtitle: .customizationsThemeModeSubtitle,
                selection: $viewModel.selectedThemeMode,
                optionTitle: \.title
            )
            .settingsRow(SettingsItems.themeMode.key)
            FontPickerRow(
                title: .customizationsFontFamilyTitle,
                subtitle: .customizationsFontFamilySubtitle,
                fontFamilyName: Binding(
                    get: {
                        if case .custom(fontFamily: let name) = viewModel.selectedFontFamily { return name }
                        return nil
                    },
                    set: { name in
                        viewModel.selectedFontFamily = if let name { .custom(fontFamily: name) } else { .default }
                    }
                )
            )
            .settingsRow(SettingsItems.fontFamily.key)
            NavigationLink {
                CustomElementsScreen()
            } label: {
                VStack(alignment: .leading) {
                    Text(.customizationsCustomElementsTitle)
                        .font(.bodyText)
                    Text(.customizationsCustomElementsSubtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .settingsRow(SettingsItems.customElements.key)
        }
    }

    var uiCallbackSection: some View {
        Section(.customizationsUICallbackSectionTitle) {
            ToggleRow(
                title: .customizationsUICallbackTitle,
                subtitle: .customizationsUICallbackSubtitle,
                isOn: $viewModel.enableCustomUICallback
            )
            .settingsRow(SettingsItems.enableCustomUICallback.key)
        }
    }
}

#Preview {
    NavigationStack {
        CustomizationsScreen()
    }
}
