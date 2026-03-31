//
//  SettingsRow.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 31/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct SettingsRow<Content: View>: View {
    var title: LocalizedStringResource
    var subtitle: LocalizedStringResource?
    var isEnabled: Bool = true
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading) {
            SettingsRowHeader(title: title, subtitle: subtitle)
            content
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : SettingsRowHeader.disabledOpacity)
    }
}
