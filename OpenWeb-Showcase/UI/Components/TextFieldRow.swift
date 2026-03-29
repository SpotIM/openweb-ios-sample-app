//
//  TextFieldRow.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct TextFieldRow: View {
    private struct Metrics {
        static let disabledOpacity: Double = 0.4
    }

    var title: LocalizedStringResource
    var subtitle: LocalizedStringResource?
    var placeholder: LocalizedStringResource
    @Binding var text: String
    var isEnabled: Bool = true

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.bodyText)
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            TextField(text: $text) {
                Text(placeholder)
            }
                .textFieldStyle(.roundedBorder)
                .disabled(!isEnabled)
        }
        .opacity(isEnabled ? 1 : Metrics.disabledOpacity)
    }
}
