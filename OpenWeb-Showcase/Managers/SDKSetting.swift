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
struct SDKSetting<Value: Codable & SDKApplicable> {

    private let key: String
    private let defaultValue: Value
    private let store: UserDefaults

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

    static subscript<EnclosingSelf: ObservableObject & Sendable>(
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

    private static func registerResetObserver<EnclosingSelf: ObservableObject & Sendable>(for instance: EnclosingSelf) {
        let alreadyRegistered = objc_getAssociatedObject(instance, &SDKSettingResetObserverKey.key) != nil
        guard !alreadyRegistered else { return }

        let observer = NotificationCenter.default.addObserver(
            forName: SettingsManager.didResetNotification,
            object: nil,
            queue: .main
        ) { [weak instance] _ in
            (instance?.objectWillChange as? ObservableObjectPublisher)?.send()
        }

        objc_setAssociatedObject(instance, &SDKSettingResetObserverKey.key, observer, .OBJC_ASSOCIATION_RETAIN)
    }
}

private enum SDKSettingResetObserverKey {
    static var key = 0
}
