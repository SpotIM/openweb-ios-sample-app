//
//  SettingsScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct SettingsScreen: View {
    private struct Metrics {
        static let sectionSpacing: CGFloat = 12
        static let contentPadding: CGFloat = 16
    }

    @StateObject private var viewModel = SettingsScreenViewModel()

    var body: some View {
        List {
            ForEach(viewModel.sections) { section in
                NavigationLink(value: section) {
                    SettingsSectionRow(section: section)
                }
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
