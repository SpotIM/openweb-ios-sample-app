//
//  SettingsScreenViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import Combine

class SettingsScreenViewModel: ObservableObject {
    let sections: [SettingsSection] = SettingsSection.allCases

    @Published var searchText = ""

    var filteredResults: [(entry: SettingsEntry, section: SettingsSection)] {
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return [] }
        return sections.flatMap { section in
            section.entries.filter { $0.matches(trimmed) }.map { (entry: $0, section: section) }
        }
    }

    var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
