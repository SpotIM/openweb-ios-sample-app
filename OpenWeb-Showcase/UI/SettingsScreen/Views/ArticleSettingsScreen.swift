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
    @State private var activeHighlightID: String?

    var body: some View {
        List {
            SegmentedPickerRow(
                title: .articleSettingsInformationStrategyTitle,
                subtitle: .articleSettingsInformationStrategySubtitle,
                selection: $viewModel.selectedInformationStrategy,
                optionTitle: \.title
            )
            .settingsRow("information_strategy", highlightedID: activeHighlightID)
            TextFieldRow(
                title: .articleSettingsAssociatedURLTitle,
                placeholder: .articleSettingsAssociatedURLPlaceholder,
                text: $viewModel.articleAssociatedURL,
                isEnabled: viewModel.isAssociatedURLEnabled
            )
            .settingsRow("article_associated_url", highlightedID: activeHighlightID)
            ToggleRow(
                title: .articleSettingsHideHeaderTitle,
                subtitle: .articleSettingsHideHeaderSubtitle,
                isOn: $viewModel.hideArticleHeader
            )
            .settingsRow("hide_article_header", highlightedID: activeHighlightID)
            SegmentedPickerRow(
                title: .articleSettingsReadOnlyModeTitle,
                subtitle: .articleSettingsReadOnlyModeSubtitle,
                selection: $viewModel.selectedReadOnlyMode,
                optionTitle: \.title
            )
            .settingsRow("read_only_mode", highlightedID: activeHighlightID)
        }
        .scrollAndHighlight(entryID: highlightedEntryID, activeHighlightID: $activeHighlightID)
        .navigationTitle(.articleSettingsScreenTitle)
        .settingsToolbar()
    }
}

#Preview {
    NavigationStack {
        ArticleSettingsScreen()
    }
}
