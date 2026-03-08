//
//  SettingsItem.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Foundation

struct SettingsItem<T: Codable> {
    let key: String
    let defaultValue: T
}
