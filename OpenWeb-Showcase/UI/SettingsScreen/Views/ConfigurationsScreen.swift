//
//  ConfigurationsScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import OpenWebSDK

struct ConfigurationsScreen: View {
    private struct Metrics {
        static let disabledOpacity: Double = 0.4
    }

    @StateObject private var viewModel = ConfigurationsViewModel()
    var highlightedEntryID: String?

    var body: some View {
        List {
            SegmentedPickerRow(
                title: .configurationsLanguageStrategyTitle,
                subtitle: .configurationsLanguageStrategySubtitle,
                selection: $viewModel.selectedLanguageStrategy,
                optionTitle: \.title
            )
            .settingsRow(SettingsItems.languageStrategy.key)
            Picker(.configurationsLanguageTitle, selection: $viewModel.selectedLanguage) {
                ForEach(OWSupportedLanguage.showcaseLanguages) { language in
                    Text(language.displayName).tag(language)
                }
            }
            .disabled(!viewModel.isCustomLanguageEnabled)
            .opacity(viewModel.isCustomLanguageEnabled ? 1 : Metrics.disabledOpacity)
            .settingsRow(SettingsItems.customLanguage.key)
            SegmentedPickerRow(
                title: .configurationsLocaleStrategyTitle,
                subtitle: .configurationsLocaleStrategySubtitle,
                selection: $viewModel.selectedLocaleStrategy,
                optionTitle: \.title
            )
            .settingsRow(SettingsItems.localeStrategy.key)
            ToggleRow(
                title: .configurationsEnableLandscapeTitle,
                subtitle: .configurationsEnableLandscapeSubtitle,
                isOn: viewModel.enableLandscapeBinding
            )
            .settingsRow(SettingsItems.enableLandscape.key)
        }
        .scrollAndHighlight(entryID: highlightedEntryID)
        .navigationTitle(.configurationsScreenTitle)
        .settingsToolbar()
    }
}

#Preview {
    NavigationStack {
        ConfigurationsScreen()
    }
}
