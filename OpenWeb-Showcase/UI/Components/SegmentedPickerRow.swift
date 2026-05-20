//
//  SegmentedPickerRow.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct SegmentedPickerRow<Option: Hashable & Identifiable & CaseIterable>: View
    where Option.AllCases: RandomAccessCollection {

    var title: LocalizedStringResource
    var subtitle: LocalizedStringResource?
    @Binding var selection: Option
    var optionTitle: (Option) -> String
    var isEnabled: Bool = true

    var body: some View {
        SettingsRow(title: title, subtitle: subtitle, isEnabled: isEnabled) {
            Picker(title, selection: $selection) {
                ForEach(Option.allCases) { option in
                    Text(optionTitle(option)).tag(option)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}
