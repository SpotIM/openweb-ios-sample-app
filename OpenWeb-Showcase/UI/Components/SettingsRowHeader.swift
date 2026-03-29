//
//  SettingsRowHeader.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 29/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct SettingsRowHeader: View {
    private struct Metrics {
        static let disabledOpacity: Double = 0.4
    }

    var title: LocalizedStringResource
    var subtitle: LocalizedStringResource?

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.bodyText)
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    static var disabledOpacity: Double { Metrics.disabledOpacity }
}
