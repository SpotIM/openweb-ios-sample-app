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
            ForEach(viewModel.sections) { section in
                NavigationLink(value: section) {
                    SettingsSectionRow(section: section)
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
        .navigationTitle("settingsScreenTitle")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.resetSettings()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
            }
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
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}
