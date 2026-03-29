//
//  CustomThemeColorsScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 24/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import OpenWebSDK

struct CustomThemeColorsScreen: View {
    @StateObject private var viewModel = CustomThemeColorsViewModel()

    var body: some View {
        List {
            ForEach(OWTheme.properties, id: \.name) { property in
                themeColorRow(property.keyPath, name: property.name)
            }
        }
        .navigationTitle(.customizationsCustomThemeColorsTitle)
        .settingsToolbar()
    }
}

// MARK: - Private

private extension CustomThemeColorsScreen {
    func themeColorRow(
        _ keyPath: WritableKeyPath<OWTheme, UIColor?>,
        name: String
    ) -> some View {
        HStack {
            Toggle("", isOn: Binding(
                get: { viewModel.isEnabled(keyPath) },
                set: { _ in viewModel.toggle(keyPath) }
            ))
            .labelsHidden()
            .fixedSize()

            Text(name)
                .font(.bodyText)

            Spacer()

            if viewModel.isEnabled(keyPath) {
                HStack(spacing: Metrics.colorPickerSpacing) {
                    Text(.light)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ColorPicker(
                        "",
                        selection: Binding(
                            get: { viewModel.lightColor(keyPath) },
                            set: { viewModel.setLightColor($0, for: keyPath) }
                        )
                    )
                    .labelsHidden()
                    .fixedSize()

                    Text(.dark)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ColorPicker(
                        "",
                        selection: Binding(
                            get: { viewModel.darkColor(keyPath) },
                            set: { viewModel.setDarkColor($0, for: keyPath) }
                        )
                    )
                    .labelsHidden()
                    .fixedSize()
                }
            }
        }
    }
}

// MARK: - Metrics

private extension CustomThemeColorsScreen {
    struct Metrics {
        static let colorPickerSpacing: CGFloat = 4
    }
}

#Preview {
    NavigationStack {
        CustomThemeColorsScreen()
    }
}
