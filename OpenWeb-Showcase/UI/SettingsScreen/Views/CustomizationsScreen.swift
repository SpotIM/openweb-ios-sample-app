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
            commentActionsSection
            themeSection
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

    var commentActionsSection: some View {
        Section(.customizationsCommentActionsSectionTitle) {
            SegmentedPickerRow(
                title: .customizationsActionColorTitle,
                subtitle: .customizationsActionColorSubtitle,
                selection: $viewModel.selectedActionColor,
                optionTitle: \.title
            )
            .settingsRow(SettingsItems.actionColor.key)
            SegmentedPickerRow(
                title: .customizationsActionFontTitle,
                subtitle: .customizationsActionFontSubtitle,
                selection: $viewModel.selectedActionFont,
                optionTitle: \.title
            )
            .settingsRow(SettingsItems.actionFont.key)
        }
    }

    var themeSection: some View {
        Section(.customizationsThemeSectionTitle) {
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
            SegmentedPickerRow(
                title: .customizationsThemeModeTitle,
                subtitle: .customizationsThemeModeSubtitle,
                selection: $viewModel.selectedThemeMode,
                optionTitle: \.title
            )
            .settingsRow(SettingsItems.themeMode.key)
            NavigationLink {
                CustomThemeColorsScreen()
            } label: {
                VStack(alignment: .leading) {
                    Text(.customizationsCustomThemeColorsTitle)
                        .font(.bodyText)
                    Text(.customizationsCustomThemeColorsSubtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .settingsRow(SettingsItems.customThemeColors.key)
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
