//
//  ArticleSettingsScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct ArticleSettingsScreen: View {
    @StateObject private var viewModel = ArticleSettingsViewModel()

    var body: some View {
        List {
            SegmentedPickerSection(
                title: .articleSettingsInformationStrategyTitle,
                subtitle: .articleSettingsInformationStrategySubtitle,
                selection: $viewModel.selectedInformationStrategy,
                optionTitle: \.title
            )
            TextFieldSection(
                title: .articleSettingsAssociatedURLTitle,
                placeholder: .articleSettingsAssociatedURLPlaceholder,
                text: $viewModel.articleAssociatedURL,
                isEnabled: viewModel.isAssociatedURLEnabled
            )
            ToggleSection(
                title: .articleSettingsHideHeaderTitle,
                subtitle: .articleSettingsHideHeaderSubtitle,
                isOn: $viewModel.hideArticleHeader
            )
            SegmentedPickerSection(
                title: .articleSettingsReadOnlyModeTitle,
                subtitle: .articleSettingsReadOnlyModeSubtitle,
                selection: $viewModel.selectedReadOnlyMode,
                optionTitle: \.title
            )
        }
        .navigationTitle(.articleSettingsScreenTitle)
        .settingsToolbar()
    }
}

#Preview {
    NavigationStack {
        ArticleSettingsScreen()
    }
}
