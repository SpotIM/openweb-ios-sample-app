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
                ForEach(viewModel.filteredEntries) { entry in
                    NavigationLink(value: entry) {
                        SearchResultRow(entry: entry)
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
            settingsDestination(for: section)
        }
        .navigationDestination(for: SearchableSettingsEntry.self) { entry in
            settingsDestination(for: entry.section, highlightedEntryID: entry.id)
        }
        .searchable(text: $viewModel.searchText, placement: searchPlacement)
        .navigationTitle(.settingsScreenTitle)
        .settingsToolbar()
    }
}

// MARK: - Search Placement

private extension SettingsScreen {
    var searchPlacement: SearchFieldPlacement {
        if #available(iOS 26, *) {
            return .automatic
        } else {
            return .navigationBarDrawer(displayMode: .always)
        }
    }
}

// MARK: - Navigation

private extension SettingsScreen {
    @ViewBuilder
    func settingsDestination(for section: SettingsSection, highlightedEntryID: String? = nil) -> some View {
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
        var entry: SearchableSettingsEntry

        var body: some View {
            VStack(alignment: .leading) {
                Text(entry.title)
                if !entry.subtitle.isEmpty {
                    Text(entry.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(entry.section.title)
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
