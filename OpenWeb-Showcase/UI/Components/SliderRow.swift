//
//  SliderRow.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 29/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct SliderRow: View {
    var title: LocalizedStringResource
    var subtitle: LocalizedStringResource?
    @Binding var value: Int
    var range: ClosedRange<Double>
    var isEnabled: Bool = true

    var body: some View {
        VStack(alignment: .leading) {
            SettingsRowHeader(title: title, subtitle: subtitle)
            HStack {
                Slider(
                    value: Binding(
                        get: { Double(value) },
                        set: { value = Int($0) }
                    ),
                    in: range,
                    step: 1
                )
                Text("\(value)")
                    .monospacedDigit()
            }
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : SettingsRowHeader.disabledOpacity)
    }
}
