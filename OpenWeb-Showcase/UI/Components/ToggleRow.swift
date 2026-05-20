//
//  ToggleRow.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct ToggleRow: View {
    var title: LocalizedStringResource
    var subtitle: LocalizedStringResource?
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            SettingsRowHeader(title: title, subtitle: subtitle)
        }
    }
}
