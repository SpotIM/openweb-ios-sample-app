//
//  TextFieldSection.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct TextFieldSection: View {
    var title: LocalizedStringKey
    var subtitle: LocalizedStringKey?
    var placeholder: LocalizedStringKey
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
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
                .disabled(!isEnabled)
        }
        .opacity(isEnabled ? 1 : 0.4)
    }
}
