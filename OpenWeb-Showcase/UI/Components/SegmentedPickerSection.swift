//
//  SegmentedPickerSection.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct SegmentedPickerSection<Option: Hashable & Identifiable & CaseIterable>: View
    where Option.AllCases: RandomAccessCollection {

    var title: LocalizedStringKey
    var subtitle: LocalizedStringKey?
    @Binding var selection: Option
    var optionTitle: (Option) -> String

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
    }
}
