//
//  SegmentedPickerSection.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

private enum SegmentedPickerSectionMetrics {
    static let disabledOpacity: Double = 0.4
}

struct SegmentedPickerSection<Option: Hashable & Identifiable & CaseIterable>: View
    where Option.AllCases: RandomAccessCollection {

    var title: LocalizedStringResource
    var subtitle: LocalizedStringResource?
    @Binding var selection: Option
    var optionTitle: (Option) -> String
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
            Picker(title, selection: $selection) {
                ForEach(Option.allCases) { option in
                    Text(optionTitle(option)).tag(option)
                }
            }
            .pickerStyle(.segmented)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : SegmentedPickerSectionMetrics.disabledOpacity)
    }
}
