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

    var body: some View {
        List {
            sortingSection
            commentActionsSection
            themeSection
            uiCallbackSection
        }
        .navigationTitle(.customizationsScreenTitle)
        .settingsToolbar()
    }
}

// MARK: - Sections

private extension CustomizationsScreen {
    var sortingSection: some View {
        Section(.customizationsSortingSectionTitle) {
            SegmentedPickerSection(
                title: .customizationsSortOptionTitle,
                subtitle: .customizationsSortOptionSubtitle,
                selection: $viewModel.selectedSortOption,
                optionTitle: \.title
            )
        }
    }

    var commentActionsSection: some View {
        Section(.customizationsCommentActionsSectionTitle) {
            SegmentedPickerSection(
                title: .customizationsActionColorTitle,
                subtitle: .customizationsActionColorSubtitle,
                selection: $viewModel.selectedActionColor,
                optionTitle: \.title
            )
            SegmentedPickerSection(
                title: .customizationsActionFontTitle,
                subtitle: .customizationsActionFontSubtitle,
                selection: $viewModel.selectedActionFont,
                optionTitle: \.title
            )
        }
    }

    var themeSection: some View {
        Section(.customizationsThemeSectionTitle) {
            SegmentedPickerSection(
                title: .customizationsFontFamilyTitle,
                subtitle: .customizationsFontFamilySubtitle,
                selection: $viewModel.selectedFontFamily,
                optionTitle: \.title
            )
            SegmentedPickerSection(
                title: .customizationsThemeModeTitle,
                subtitle: .customizationsThemeModeSubtitle,
                selection: $viewModel.selectedThemeMode,
                optionTitle: \.title
            )
            NavigationLink {
                // swiftlint:disable:next todo
                // TODO: Custom Theme Colors screen
                Text("Coming soon")
            } label: {
                VStack(alignment: .leading) {
                    Text(.customizationsCustomThemeColorsTitle)
                        .font(.bodyText)
                    Text(.customizationsCustomThemeColorsSubtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    var uiCallbackSection: some View {
        Section(.customizationsUICallbackSectionTitle) {
            ToggleSection(
                title: .customizationsUICallbackTitle,
                subtitle: .customizationsUICallbackSubtitle,
                isOn: $viewModel.enableCustomUICallback
            )
        }
    }
}

#Preview {
    NavigationStack {
        CustomizationsScreen()
    }
}
