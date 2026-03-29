//
//  ConfigurationsScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct ConfigurationsScreen: View {
    private struct Metrics {
        static let disabledOpacity: Double = 0.4
    }

    @StateObject private var viewModel = ConfigurationsViewModel()
    var highlightedEntryID: String?
    @State private var activeHighlightID: String?

    var body: some View {
        List {
            SegmentedPickerRow(
                title: .configurationsLanguageStrategyTitle,
                subtitle: .configurationsLanguageStrategySubtitle,
                selection: $viewModel.selectedLanguageStrategy,
                optionTitle: \.title
            )
            .settingsRow("language_strategy", highlightedID: activeHighlightID)
            Picker(.configurationsLanguageTitle, selection: $viewModel.selectedLanguage) {
                ForEach(ConfigurationsViewModel.SupportedLanguage.allCases) { language in
                    Text(language.title).tag(language)
                }
            }
            .disabled(!viewModel.isCustomLanguageEnabled)
            .opacity(viewModel.isCustomLanguageEnabled ? 1 : Metrics.disabledOpacity)
            .settingsRow("language", highlightedID: activeHighlightID)
            SegmentedPickerRow(
                title: .configurationsLocaleStrategyTitle,
                subtitle: .configurationsLocaleStrategySubtitle,
                selection: $viewModel.selectedLocaleStrategy,
                optionTitle: \.title
            )
            .settingsRow("locale_strategy", highlightedID: activeHighlightID)
            ToggleRow(
                title: .configurationsEnableLandscapeTitle,
                subtitle: .configurationsEnableLandscapeSubtitle,
                isOn: viewModel.enableLandscapeBinding
            )
            .settingsRow("enable_landscape", highlightedID: activeHighlightID)
        }
        .scrollAndHighlight(entryID: highlightedEntryID, activeHighlightID: $activeHighlightID)
        .navigationTitle(.configurationsScreenTitle)
        .settingsToolbar()
    }
}

#Preview {
    NavigationStack {
        ConfigurationsScreen()
    }
}
