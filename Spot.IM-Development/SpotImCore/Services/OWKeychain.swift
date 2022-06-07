//
//  OWKeychain.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/06/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

protocol OWKeychainProtocol {
    func save<T>(value: T, forKey key: OWKeychain.OWKeychainKey<T>)
    func get<T>(key: OWKeychain.OWKeychainKey<T>) -> T?
    func remove<T>(key: OWKeychain.OWKeychainKey<T>)
}

class OWKeychain : OWKeychainProtocol {
    fileprivate struct Metrics {
        static let kSecAttrService = "com.open-web.sdk"
    }
    
    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate let encoder: JSONEncoder
    fileprivate let decoder: JSONDecoder
    
    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         encoder: JSONEncoder = JSONEncoder(),
         decoder: JSONDecoder = JSONDecoder()) {
        self.servicesProvider = servicesProvider
        self.encoder = encoder
        self.decoder = decoder
    }
    
    enum OWKeychainKey<T: Codable>: String {
        case guestSessionUserId = "session.guest.userId"
        case loggedInUserSession = "session.user"
        case authorizationSessionToken = "session.authorization.token"
        case openwebSessionToken = "session.openweb.toekn"
        case reportedCommentsSession = "session.reported.comments"
        case isMigratedToKeychain = "keychain.data.migration"
    }
    
    func save<T>(value: T, forKey key: OWKeychainKey<T>) {
        guard let encodedData = try? encoder.encode(value) else {
            servicesProvider.logger().log(level: .error, "Failed to encode data for key: \(key.rawValue) before writing to Keychain")
            return
        }
        _save(data: encodedData, forKey: key)
    }
    
    func get<T>(key: OWKeychainKey<T>) -> T? {
        guard let data = _get(key: key) else {
            return nil
        }
        
        guard let valueToReturn = try? decoder.decode(T.self, from: data) else {
            servicesProvider.logger().log(level: .error, "Failed to decode data for key: \(key.rawValue) to class: \(T.self) after retrieving from Keychain")
            return nil
        }
        
        return valueToReturn
    }
    
    func remove<T>(key: OWKeychainKey<T>) {
        _remove(key: key)
    }
}

fileprivate extension OWKeychain.OWKeychainKey {
    // Add description for better understanding of future cases (keys)
    var description: String? {
        switch self {
        case .guestSessionUserId:
            return "The user Id of a guest user"
        case .loggedInUserSession:
            return "The logged in user data"
        case .authorizationSessionToken:
            return "The auth token which arrived in the authorization header"
        case .openwebSessionToken:
            return "The token which arrived in x-openweb-token"
        case .reportedCommentsSession:
            return "Reported comments"
        case .isMigratedToKeychain:
            return "Is a migration from user defaults to keychain was done"
        }
    }
}

fileprivate extension OWKeychain {
    func query<T>(forKey key: OWKeychainKey<T>) -> [String: Any] {
        var query: [String: Any] = [
            String(kSecClass): kSecClassGenericPassword,
            String(kSecAttrService): Metrics.kSecAttrService,
            String(kSecAttrAccount): key.rawValue,
            String(kSecMatchLimit): kSecMatchLimitOne
        ]
        if let des = key.description, !des.isEmpty {
            query[String(kSecAttrDescription)] = des
        }
        return query
    }
    
    func _save<T>(data: Data, forKey key: OWKeychainKey<T>) {
        var query = query(forKey: key)
        
        let searchStatus = SecItemCopyMatching(query as CFDictionary, nil)
        switch searchStatus {
        case errSecSuccess:
            let attributes: [String: Any] = [
                String(kSecValueData): data
            ]
            let writeStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            if writeStatus != errSecSuccess {
                servicesProvider.logger().log(level: .error, "Failed to write to Keychain using SecItemUpdate with key: \(key.rawValue)")
            }
        case errSecItemNotFound:
            query[String(kSecValueData)] = data
            let writeStatus = SecItemAdd(query as CFDictionary, nil)
            if writeStatus != errSecSuccess {
                servicesProvider.logger().log(level: .error, "Failed to write to Keychain using SecItemAdd with key: \(key.rawValue)")
            }
        default:
            servicesProvider.logger().log(level: .error, "Failed to write to Keychain with key: \(key.rawValue), got status: \(searchStatus.description) when using SecItemCopyMatching")
        }
    }
    
    func _get<T>(key: OWKeychainKey<T>) -> Data? {
        var query = query(forKey: key)
        query[String(kSecReturnAttributes)] = kCFBooleanTrue
        query[String(kSecReturnData)] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        let searchStatus = SecItemCopyMatching(query as CFDictionary, &queryResult)
        switch searchStatus {
        case errSecSuccess:
            guard let queriedItem = queryResult as? [String: Any],
                  let data = queriedItem [String(kSecValueData)] as? Data else {
                      servicesProvider.logger().log(level: .error, "Failed to get value from Keychain using SecItemCopyMatching with key: \(key.rawValue)")
                      return nil
            }
            return data
        case errSecItemNotFound:
            return nil
        default:
            servicesProvider.logger().log(level: .error, "Failed to get value from Keychain using SecItemCopyMatching with key: \(key.rawValue), got status: \(searchStatus.description)")
            return nil
        }
    }
    
    func _remove<T>(key: OWKeychainKey<T>) {
        let query = query(forKey: key)
        
        let removeStatus = SecItemDelete(query as CFDictionary)
        if removeStatus != errSecSuccess && removeStatus != errSecItemNotFound {
            servicesProvider.logger().log(level: .error, "Failed to remove data from Keychain using SecItemDelete with key: \(key.rawValue)")
        }
    }
}
