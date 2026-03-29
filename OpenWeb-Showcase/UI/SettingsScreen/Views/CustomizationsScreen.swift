//
//  CustomizationsScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct CustomizationsScreen: View {
    @StateObject private var viewModel = CustomizationsViewModel()
    var highlightedEntryID: String?
    @State private var activeHighlightID: String?

    var body: some View {
        List {
            sortingSection
            commentActionsSection
            themeSection
            uiCallbackSection
        }
        .scrollAndHighlight(entryID: highlightedEntryID, activeHighlightID: $activeHighlightID)
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
            .settingsRow("sort_option", highlightedID: activeHighlightID)
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
            .settingsRow("action_color", highlightedID: activeHighlightID)
            SegmentedPickerRow(
                title: .customizationsActionFontTitle,
                subtitle: .customizationsActionFontSubtitle,
                selection: $viewModel.selectedActionFont,
                optionTitle: \.title
            )
            .settingsRow("action_font", highlightedID: activeHighlightID)
        }
    }

    var themeSection: some View {
        Section(.customizationsThemeSectionTitle) {
            SegmentedPickerRow(
                title: .customizationsFontFamilyTitle,
                subtitle: .customizationsFontFamilySubtitle,
                selection: $viewModel.selectedFontFamily,
                optionTitle: \.title
            )
            .settingsRow("font_family", highlightedID: activeHighlightID)
            SegmentedPickerRow(
                title: .customizationsThemeModeTitle,
                subtitle: .customizationsThemeModeSubtitle,
                selection: $viewModel.selectedThemeMode,
                optionTitle: \.title
            )
            .settingsRow("theme_mode", highlightedID: activeHighlightID)
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
            .settingsRow("custom_theme_colors", highlightedID: activeHighlightID)
        }
    }

    var uiCallbackSection: some View {
        Section(.customizationsUICallbackSectionTitle) {
            ToggleRow(
                title: .customizationsUICallbackTitle,
                subtitle: .customizationsUICallbackSubtitle,
                isOn: $viewModel.enableCustomUICallback
            )
            .settingsRow("custom_ui_callback", highlightedID: activeHighlightID)
        }
    }
}

#Preview {
    NavigationStack {
        CustomizationsScreen()
    }
}
