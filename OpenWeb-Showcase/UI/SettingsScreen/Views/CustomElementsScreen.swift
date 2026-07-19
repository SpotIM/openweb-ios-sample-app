//
//  CustomElementsScreen.swift
//  OpenWeb-Showcase
//
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import OpenWebSDK

struct CustomElementsScreen: View {
    @StateObject private var viewModel = CustomElementsViewModel()

    var body: some View {
        List {
            Section(.customizationsElementsTextSectionTitle) {
                ForEach(CustomElementsViewModel.textElementProperties, id: \.name) { property in
                    textElementRow(property.keyPath, name: property.name)
                }
            }
            Section(.customizationsElementsColorSectionTitle) {
                ForEach(CustomElementsViewModel.colorElementProperties, id: \.name) { property in
                    colorToggleRow(property.keyPath, label: property.name)
                }
            }
        }
        .navigationTitle(.customizationsCustomElementsTitle)
        .settingsToolbar()
    }
}

// MARK: - Text Element Row

private extension CustomElementsScreen {
    func textElementRow(
        _ keyPath: WritableKeyPath<OWCustomizationElements, OWCustomizationTextElement>,
        name: String
    ) -> some View {
        DisclosureGroup(name) {
            fontFamilyPicker(for: keyPath)
            fontWeightPicker(for: keyPath)
            colorToggleRow(keyPath, label: String(localized: .customizationsElementsColorLabel))
        }
        .font(.bodyText)
    }

    func fontFamilyPicker(for keyPath: WritableKeyPath<OWCustomizationElements, OWCustomizationTextElement>) -> some View {
        FontPickerRow(
            title: .customizationsElementsFontFamilyLabel,
            fontFamilyName: Binding(
                get: { viewModel.fontFamily(for: keyPath) },
                set: { viewModel.setFontFamily($0, for: keyPath) }
            )
        )
    }

    func fontWeightPicker(for keyPath: WritableKeyPath<OWCustomizationElements, OWCustomizationTextElement>) -> some View {
        HStack {
            Text(String(localized: .customizationsElementsFontWeightLabel))
                .font(.bodyText)
            Spacer()
            Picker("", selection: Binding(
                get: { viewModel.fontWeight(for: keyPath)?.rawValue ?? Metrics.nilSentinel },
                set: { viewModel.setFontWeight($0 == Metrics.nilSentinel ? nil : UIFont.Weight(rawValue: $0), for: keyPath) }
            )) {
                ForEach(CustomElementsViewModel.fontWeightOptions, id: \.name) { option in
                    Text(option.name).tag(option.weight?.rawValue ?? Metrics.nilSentinel)
                }
            }
            .pickerStyle(.menu)
        }
    }

}

// MARK: - Shared Components

private extension CustomElementsScreen {
    func colorToggleRow<T: OWColorCustomizing>(
        _ keyPath: WritableKeyPath<OWCustomizationElements, T>,
        label: String
    ) -> some View {
        HStack {
            Toggle("", isOn: Binding(
                get: { viewModel.isColorEnabled(keyPath) },
                set: { _ in viewModel.toggleColor(keyPath) }
            ))
            .labelsHidden()
            .fixedSize()

            Text(label)
                .font(.bodyText)

            Spacer()

            if viewModel.isColorEnabled(keyPath) {
                colorPickers(
                    light: Binding(
                        get: { viewModel.lightColor(keyPath) },
                        set: { viewModel.setLightColor($0, for: keyPath) }
                    ),
                    dark: Binding(
                        get: { viewModel.darkColor(keyPath) },
                        set: { viewModel.setDarkColor($0, for: keyPath) }
                    )
                )
            }
        }
    }

    func colorPickers(light: Binding<Color>, dark: Binding<Color>) -> some View {
        HStack(spacing: Metrics.colorPickerSpacing) {
            Text(.light)
                .font(.caption)
                .foregroundStyle(.secondary)
            ColorPicker("", selection: light)
                .labelsHidden()
                .fixedSize()

            Text(.dark)
                .font(.caption)
                .foregroundStyle(.secondary)
            ColorPicker("", selection: dark)
                .labelsHidden()
                .fixedSize()
        }
    }
}

// MARK: - Metrics

private extension CustomElementsScreen {
    struct Metrics {
        static let colorPickerSpacing: CGFloat = 4
        static let nilSentinel: CGFloat = -999
    }
}

#Preview {
    NavigationStack {
        CustomElementsScreen()
    }
}
