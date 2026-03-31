//
//  SettingsItem.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Foundation

protocol AnySettingsItem {
    func applyDefaultToSDK()
}

struct SettingsItem<T: Codable & OpenWebApplicable> {
    var key: String
    var defaultValue: T
}

extension SettingsItem: AnySettingsItem {
    func applyDefaultToSDK() {
        defaultValue.applyToSDK()
    }
}
