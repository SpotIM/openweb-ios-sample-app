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
                    NavigationLink(value: entry.section) {
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
            switch section {
            case .customizations:
                CustomizationsScreen()
            case .configurations:
                ConfigurationsScreen()
            case .articleSettings:
                ArticleSettingsScreen()
            case .screenSettings:
                ScreenSettingsScreen()
            }
        }
        .searchable(text: $viewModel.searchText)
        .navigationTitle(.settingsScreenTitle)
        .settingsToolbar()
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
