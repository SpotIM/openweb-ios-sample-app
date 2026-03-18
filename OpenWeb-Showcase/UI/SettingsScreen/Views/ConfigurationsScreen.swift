//
//  ConfigurationsScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct ConfigurationsScreen: View {
    @StateObject private var viewModel = ConfigurationsViewModel()

    var body: some View {
        List {
            SegmentedPickerSection(
                title: .configurationsLanguageStrategyTitle,
                subtitle: .configurationsLanguageStrategySubtitle,
                selection: $viewModel.selectedLanguageStrategy,
                optionTitle: \.title
            )
            Picker(.configurationsLanguageTitle, selection: $viewModel.selectedLanguage) {
                ForEach(ConfigurationsViewModel.SupportedLanguage.allCases) { language in
                    Text(language.title).tag(language)
                }
            }
            .disabled(!viewModel.isCustomLanguageEnabled)
            .opacity(viewModel.isCustomLanguageEnabled ? 1 : 0.4)
            SegmentedPickerSection(
                title: .configurationsLocaleStrategyTitle,
                subtitle: .configurationsLocaleStrategySubtitle,
                selection: $viewModel.selectedLocaleStrategy,
                optionTitle: \.title
            )
            ToggleSection(
                title: .configurationsEnableLandscapeTitle,
                subtitle: .configurationsEnableLandscapeSubtitle,
                isOn: viewModel.enableLandscapeBinding
            )
        }
        .navigationTitle(.configurationsScreenTitle)
        .settingsToolbar()
    }
}

#Preview {
    NavigationStack {
        ConfigurationsScreen()
    }
}
