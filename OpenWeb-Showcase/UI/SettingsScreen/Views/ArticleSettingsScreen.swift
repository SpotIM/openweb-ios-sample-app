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
    var highlightedEntryID: String?

    var body: some View {
        List {
            SegmentedPickerRow(
                title: .articleSettingsInformationStrategyTitle,
                subtitle: .articleSettingsInformationStrategySubtitle,
                selection: $viewModel.selectedInformationStrategy,
                optionTitle: \.title
            )
            .settingsRow(SettingsItems.informationStrategy.key)
            TextFieldRow(
                title: .articleSettingsAssociatedURLTitle,
                placeholder: .articleSettingsAssociatedURLPlaceholder,
                text: $viewModel.articleAssociatedURL,
                isEnabled: viewModel.isAssociatedURLEnabled
            )
            .settingsRow(SettingsItems.articleAssociatedURL.key)
            ToggleRow(
                title: .articleSettingsHideHeaderTitle,
                subtitle: .articleSettingsHideHeaderSubtitle,
                isOn: $viewModel.hideArticleHeader
            )
            .settingsRow(SettingsItems.hideArticleHeader.key)
            SegmentedPickerRow(
                title: .articleSettingsReadOnlyModeTitle,
                subtitle: .articleSettingsReadOnlyModeSubtitle,
                selection: $viewModel.selectedReadOnlyMode,
                optionTitle: \.title
            )
            .settingsRow(SettingsItems.readOnlyMode.key)
        }
        .scrollAndHighlight(entryID: highlightedEntryID)
        .navigationTitle(.articleSettingsScreenTitle)
        .settingsToolbar()
    }
}

#Preview {
    NavigationStack {
        ArticleSettingsScreen()
    }
}
