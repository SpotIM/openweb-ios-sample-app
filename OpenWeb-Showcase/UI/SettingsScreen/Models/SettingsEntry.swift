//
//  SettingsEntry.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 25/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Foundation

struct SettingsEntry: Identifiable, Hashable {
    var id: String
    var title: String
    var subtitle: String
}

extension SettingsEntry {
    func matches(_ query: String) -> Bool {
        let lowercased = query.lowercased()
        return title.lowercased().contains(lowercased) ||
               subtitle.lowercased().contains(lowercased)
    }
}
