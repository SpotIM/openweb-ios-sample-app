//
//  UserDefaultsProvider.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 08/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

protocol UserDefaultsProviderProtocol {
    func get<T>(key: UserDefaultsProvider.UDKey<T>) -> T?
    func get<T>(key: UserDefaultsProvider.UDKey<T>, defaultValue: T) -> T
    func save<T>(value: T, forKey key: UserDefaultsProvider.UDKey<T>)
    func remove<T>(key: UserDefaultsProvider.UDKey<T>)
}

class UserDefaultsProvider : UserDefaultsProviderProtocol {
    // Singleton
    static let shared: UserDefaultsProviderProtocol = UserDefaultsProvider()
    
    fileprivate struct Metrics {
        static let suiteName = "com.open-web.demo-app"
    }
    
    fileprivate let encoder: JSONEncoder
    fileprivate let decoder: JSONDecoder
    fileprivate let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults(suiteName: Metrics.suiteName) ?? UserDefaults.standard,
         encoder: JSONEncoder = JSONEncoder(),
         decoder: JSONDecoder = JSONDecoder()) {
        self.userDefaults = userDefaults
        self.encoder = encoder
        self.decoder = decoder
    }
        
    func save<T>(value: T, forKey key: UDKey<T>) {
        guard let encodedData = try? encoder.encode(value) else {
            DLog("Failed to encode data for key: \(key.rawValue) before writing to UserDefaults")
            return
        }
        _save(data: encodedData, forKey: key)
    }
    
    func get<T>(key: UDKey<T>) -> T? {
        guard let data = _get(key: key) else {
            return nil
        }
        
        guard let valueToReturn = try? decoder.decode(T.self, from: data) else {
            DLog("Failed to decode data for key: \(key.rawValue) to class: \(T.self) after retrieving from UserDefaults")
            return nil
        }
        
        return valueToReturn
    }
    
    func get<T>(key: UDKey<T>, defaultValue: T) -> T {
        return get(key: key) ?? defaultValue
    }
    
    func remove<T>(key: UDKey<T>) {
        _remove(key: key)
    }
    
    enum UDKey<T: Codable>: String {
        case shouldShowOpenFullConversation = "shouldShowOpenFullConversation"
        case shouldPresentInNewNavStack = "shouldPresentInNewNavStack"
        case shouldOpenComment = "shouldOpenComment"
        case isCustomDarkModeEnabled = "demo.isCustomDarkModeEnabled"
        case isReadOnlyEnabled = "demo.isReadOnlyEnabled"
        case interfaceStyle = "demo.interfaceStyle"
        case spotIdKey = "spotIdKey"
    }
}

fileprivate extension UserDefaultsProvider.UDKey {
    // Add description for better understanding of future cases (keys)
    var description: String {
        switch self {
        case .shouldShowOpenFullConversation:
            return "Key which stores if we should open full conversation"
        case .shouldPresentInNewNavStack:
            return "Key which stores if we should present in a new navigation or push in the existing one"
        case .shouldOpenComment:
            return "Key which stores if we should show create comment button"
        case .isCustomDarkModeEnabled:
            return "Key which stores if we should override system's dark mode"
        case .isReadOnlyEnabled:
            return "Key which stores if read only mode is enabled"
        case .interfaceStyle:
            return "Key which stores if we should override system's interface style (light, dark)"
        case .spotIdKey:
            return "Key which stores the current spot id to be tested"
        }
    }
} 

fileprivate extension UserDefaultsProvider {
    func _save<T>(data: Data, forKey key: UDKey<T>) {
        DLog("Writing data to UserDefaults for key: \(key.rawValue)")
        userDefaults.set(data, forKey: key.rawValue)
    }
    
    func _get<T>(key: UDKey<T>) -> Data? {
        DLog("retrieving data from UserDefaults for key: \(key.rawValue)")
        return userDefaults.data(forKey: key.rawValue)
    }
    
    func _remove<T>(key: UDKey<T>) {
        DLog("Removing data from UserDefaults for key: \(key.rawValue)")
        userDefaults.removeObject(forKey: key.rawValue)
    }
}
