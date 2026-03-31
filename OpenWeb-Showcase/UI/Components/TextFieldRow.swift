//
//  TextFieldRow.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct TextFieldRow: View {
    var title: LocalizedStringResource
    var subtitle: LocalizedStringResource?
    var placeholder: LocalizedStringResource
    @Binding var text: String
    var isEnabled: Bool = true

    var body: some View {
        SettingsRow(title: title, subtitle: subtitle, isEnabled: isEnabled) {
            TextField(text: $text) {
                Text(placeholder)
            }
            .textFieldStyle(.roundedBorder)
        }
    }
}

struct NumericTextFieldRow: View {
    var title: LocalizedStringResource
    var subtitle: LocalizedStringResource?
    var placeholder: LocalizedStringResource
    @Binding var value: Double
    var isEnabled: Bool = true

    var body: some View {
        SettingsRow(title: title, subtitle: subtitle, isEnabled: isEnabled) {
            TextField(value: $value, format: .number) {
                Text(placeholder)
            }
            .textFieldStyle(.roundedBorder)
            .keyboardType(.decimalPad)
        }
    }
}
