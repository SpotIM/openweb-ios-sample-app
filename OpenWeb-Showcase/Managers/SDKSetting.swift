//
//  SDKSetting.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 17/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Combine
import Foundation

@propertyWrapper
struct SDKSetting<Value: Codable & OpenWebApplicable> {

    private var key: String
    private var defaultValue: Value
    private var store: UserDefaults

    init(key: String, defaultValue: Value, store: UserDefaults = SettingsManager.store) {
        self.key = key
        self.defaultValue = defaultValue
        self.store = store
    }

    init(_ item: SettingsItem<Value>, store: UserDefaults = SettingsManager.store) {
        self.init(key: item.key, defaultValue: item.defaultValue, store: store)
    }

    var wrappedValue: Value {
        get {
            guard let data = store.data(forKey: key),
                  let value = try? JSONDecoder().decode(Value.self, from: data) else {
                return defaultValue
            }
            return value
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                store.set(data, forKey: key)
            }
            newValue.applyToSDK()
        }
    }

    static subscript<EnclosingSelf: NSObject & ObservableObject & Sendable>(
        _enclosingInstance instance: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>
    ) -> Value {
        get {
            registerResetObserver(for: instance)
            return instance[keyPath: storageKeyPath].wrappedValue
        }
        set {
            (instance.objectWillChange as? ObservableObjectPublisher)?.send()
            instance[keyPath: storageKeyPath].wrappedValue = newValue
        }
    }

    private static func registerResetObserver<EnclosingSelf: NSObject & ObservableObject & Sendable>(for instance: EnclosingSelf) {
        let existing: AnyCancellable? = instance.getObjectiveCAssociatedObject(key: &SDKSettingKeys.resetObserver)
        guard existing == nil else { return }

        let cancellable = SettingsManager.didReset
            .receive(on: DispatchQueue.main)
            .sink { [weak instance] in
                (instance?.objectWillChange as? ObservableObjectPublisher)?.send()
            }

        instance.setObjectiveCAssociatedObject(key: &SDKSettingKeys.resetObserver, value: cancellable)
    }
}

private enum SDKSettingKeys {
    static var resetObserver = "SDKSettingResetObserver"
}
