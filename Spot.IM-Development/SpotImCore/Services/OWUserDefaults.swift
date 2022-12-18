//
//  OWUserDefaults.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/06/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

protocol OWUserDefaultsProtocol {
    func get<T>(key: OWUserDefaults.OWKey<T>) -> T?
    func get<T>(key: OWUserDefaults.OWKey<T>, defaultValue: T) -> T
    func save<T>(value: T, forKey key: OWUserDefaults.OWKey<T>)
    func remove<T>(key: OWUserDefaults.OWKey<T>)
}

class OWUserDefaults : OWUserDefaultsProtocol {
    fileprivate struct Metrics {
        static let suiteName = "com.open-web.sdk"
    }
    
    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate let encoder: JSONEncoder
    fileprivate let decoder: JSONDecoder
    fileprivate let userDefaults: UserDefaults
    
    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         userDefaults: UserDefaults = UserDefaults(suiteName: Metrics.suiteName) ?? UserDefaults.standard,
         encoder: JSONEncoder = JSONEncoder(),
         decoder: JSONDecoder = JSONDecoder()) {
        self.servicesProvider = servicesProvider
        self.userDefaults = userDefaults
        self.encoder = encoder
        self.decoder = decoder
    }
    
    enum OWKey<T: Codable>: String {
        case testKey = "testKey"
    }
    
    func save<T>(value: T, forKey key: OWKey<T>) {
        guard let encodedData = try? encoder.encode(value) else {
            servicesProvider.logger().log(level: .error, "Failed to encode data for key: \(key.rawValue) before writing to UserDefaults")
            return
        }
        _save(data: encodedData, forKey: key)
    }
    
    func get<T>(key: OWKey<T>) -> T? {
        guard let data = _get(key: key) else {
            return nil
        }
        
        guard let valueToReturn = try? decoder.decode(T.self, from: data) else {
            servicesProvider.logger().log(level: .error, "Failed to decode data for key: \(key.rawValue) to class: \(T.self) after retrieving from UserDefaults")
            return nil
        }
        
        return valueToReturn
    }
    
    func get<T>(key: OWKey<T>, defaultValue: T) -> T {
        return get(key: key) ?? defaultValue
    }
    
    func remove<T>(key: OWKey<T>) {
        _remove(key: key)
    }
}

fileprivate extension OWUserDefaults.OWKey {
    // Add description for better understanding of future cases (keys)
    var description: String {
        switch self {
        case .testKey:
            return "Just a test, remove after we add a real key"
        }
    }
}

fileprivate extension OWUserDefaults {
    func _save<T>(data: Data, forKey key: OWKey<T>) {
        servicesProvider.logger().log(level: .verbose, "Writing data to UserDefaults for key: \(key.rawValue)")
        userDefaults.set(data, forKey: key.rawValue)
    }
    
    func _get<T>(key: OWKey<T>) -> Data? {
        servicesProvider.logger().log(level: .verbose, "retrieving data from UserDefaults for key: \(key.rawValue)")
        return userDefaults.data(forKey: key.rawValue)
    }
    
    func _remove<T>(key: OWKey<T>) {
        servicesProvider.logger().log(level: .verbose, "Removing data from UserDefaults for key: \(key.rawValue)")
        userDefaults.removeObject(forKey: key.rawValue)
    }
}

