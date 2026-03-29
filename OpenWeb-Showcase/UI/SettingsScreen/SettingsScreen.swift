//
//  SettingsScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct SettingsScreen: View {
    @StateObject private var viewModel = SettingsScreenViewModel()

    var body: some View {
        List {
            if viewModel.isSearching {
                ForEach(viewModel.filteredResults, id: \.entry.id) { result in
                    NavigationLink(value: result.entry) {
                        SearchResultRow(entry: result.entry, section: result.section)
                    }
                }
            } else {
                ForEach(viewModel.sections) { section in
                    NavigationLink(value: section) {
                        SettingsSectionRow(section: section)
                    }
                }
            }
        }
        .navigationDestination(for: SettingsSection.self) { section in
            settingsDestination(section: section)
        }
        .navigationDestination(for: SettingsEntry.self) { entry in
            let section = SettingsSection.allCases.first { $0.entries.contains(entry) }
            settingsDestination(section: section ?? .customizations, highlightedEntryID: entry.id)
        }
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle(.settingsScreenTitle)
        .settingsToolbar()
    }
}

// MARK: - Navigation

private extension SettingsScreen {
    @ViewBuilder
    func settingsDestination(section: SettingsSection, highlightedEntryID: String? = nil) -> some View {
        switch section {
        case .customizations:
            CustomizationsScreen(highlightedEntryID: highlightedEntryID)
        case .configurations:
            ConfigurationsScreen(highlightedEntryID: highlightedEntryID)
        case .articleSettings:
            ArticleSettingsScreen(highlightedEntryID: highlightedEntryID)
        case .screenSettings:
            ScreenSettingsScreen(highlightedEntryID: highlightedEntryID)
        }
    }
}

// MARK: - Subviews

private extension SettingsScreen {
    struct SettingsSectionRow: View {
        var section: SettingsSection

        var body: some View {
            VStack(alignment: .leading) {
                Text(section.title)
                Text(section.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    struct SearchResultRow: View {
        var entry: SettingsEntry
        var section: SettingsSection

        var body: some View {
            VStack(alignment: .leading) {
                Text(entry.title)
                if !entry.subtitle.isEmpty {
                    Text(entry.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(section.title)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}
