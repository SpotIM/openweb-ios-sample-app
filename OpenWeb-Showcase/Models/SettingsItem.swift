//
//  SettingsItem.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Foundation

protocol AnySettingsItem {
    func resetToDefault(defaults: UserDefaults, encoder: JSONEncoder)
}

struct SettingsItem<T: Codable> {
    let key: String
    let defaultValue: T
}

extension SettingsItem: AnySettingsItem {
    func resetToDefault(defaults: UserDefaults, encoder: JSONEncoder) {
        if let data = try? encoder.encode(defaultValue) {
            defaults.set(data, forKey: key)
        }
    }
}
