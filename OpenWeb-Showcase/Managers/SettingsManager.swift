//
//  SettingsManager.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Foundation

protocol SDKApplicable {
    func applyToSDK()
}

class SettingsManager {
    static let shared = SettingsManager()

    private static let suiteName = "com.open-web.showcase-app"
    static let store = UserDefaults(suiteName: suiteName) ?? UserDefaults.standard
    private let defaults: UserDefaults = SettingsManager.store
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {}

    func get<T: Codable>(_ item: SettingsItem<T>) -> T {
        guard let data = defaults.data(forKey: item.key) else { return item.defaultValue }
        return (try? decoder.decode(T.self, from: data)) ?? item.defaultValue
    }

    func set<T: Codable>(_ item: SettingsItem<T>, value: T) {
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: item.key)
        }
        (value as? SDKApplicable)?.applyToSDK()
    }

    func resetAll() {
        defaults.removePersistentDomain(forName: Self.suiteName)
        SettingsItems.allItems.forEach { $0.applyDefaultToSDK() }
    }
}
