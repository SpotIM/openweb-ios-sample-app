//
//  OWKeychain.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/06/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWKeychainProtocol: OWKeychainRxProtocol {
    func save<T>(value: T, forKey key: OWKeychain.OWKey<T>)
    func get<T>(key: OWKeychain.OWKey<T>) -> T?
    func remove<T>(key: OWKeychain.OWKey<T>)
    var rxProtocol: OWKeychainRxProtocol { get }
}

protocol OWKeychainRxProtocol {
    func values<T>(key: OWKeychain.OWKey<T>, defaultValue: T?) -> Observable<T>
    func values<T>(key: OWKeychain.OWKey<T>) -> Observable<T>
    func setValues<T>(key: OWKeychain.OWKey<T>) -> Binder<T>
}

class OWKeychain: ReactiveCompatible, OWKeychainProtocol {
    fileprivate struct Metrics {
        static let kSecAttrService = "com.open-web.sdk"
    }

    var rxProtocol: OWKeychainRxProtocol { return self }
    fileprivate var rxHelper: OWPersistenceRxHelperProtocol

    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate let encoder: JSONEncoder
    fileprivate let decoder: JSONDecoder

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         encoder: JSONEncoder = JSONEncoder(),
         decoder: JSONDecoder = JSONDecoder()) {
        self.servicesProvider = servicesProvider
        self.encoder = encoder
        self.decoder = decoder
        self.rxHelper = OWPersistenceRxHelper(decoder: decoder, encoder: encoder)
    }

    enum OWKey<T: Codable>: String, OWRawableKey {
        case guestSessionUserId = "session.guest.userId"
        case loggedInUserSession = "session.user"
        case authorizationSessionToken = "session.authorization.token"
        case openwebSessionToken = "session.openweb.toekn"
        case reportedCommentsSession = "session.reported.comments"

        // New keys - after the rafactor and new API
        case networkCredentials = "networkCredentialsKey"
    }

    func save<T>(value: T, forKey key: OWKey<T>) {
        guard let encodedData = try? encoder.encode(value) else {
            servicesProvider.logger().log(level: .error, "Failed to encode data for key: \(key.rawValue) before writing to Keychain")
            return
        }

        rxHelper.onNext(key: OWRxHelperKey<T>(key: key), data: encodedData)

        _save(data: encodedData, forKey: key)
    }

    func get<T>(key: OWKey<T>) -> T? {
        guard let data = _get(key: key) else {
            return nil
        }

        guard let valueToReturn = try? decoder.decode(T.self, from: data) else {
            servicesProvider.logger().log(level: .error, "Failed to decode data for key: \(key.rawValue) to class: \(T.self) after retrieving from Keychain")
            return nil
        }

        return valueToReturn
    }

    func remove<T>(key: OWKey<T>) {
        _remove(key: key)
    }
}

fileprivate extension OWKeychain.OWKey {
    // Add description for better understanding of future cases (keys)
    var description: String {
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
        case .networkCredentials:
            return "The credentials information for the active user/openweb BE required credentials"
        }
    }
}

fileprivate extension OWKeychain {
    func query<T>(forKey key: OWKey<T>) -> [String: Any] {
        let query: [String: Any] = [
            String(kSecClass): kSecClassGenericPassword,
            String(kSecAttrService): Metrics.kSecAttrService,
            String(kSecAttrAccount): key.rawValue,
            String(kSecAttrDescription): key.description
        ]

        return query
    }

    func _save<T>(data: Data, forKey key: OWKey<T>) {
        var query = query(forKey: key)
        query[String(kSecMatchLimit)] = kSecMatchLimitOne

        let searchStatus = SecItemCopyMatching(query as CFDictionary, nil)
        // Remove the match limit as we are using the same query for writing
        query.removeValue(forKey: String(kSecMatchLimit))
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
            let message = "Failed to write to Keychain with key: \(key.rawValue), got status: \(searchStatus.description) when using SecItemCopyMatching"
            servicesProvider.logger().log(level: .error, message)
        }
    }

    func _get<T>(key: OWKey<T>) -> Data? {
        var query = query(forKey: key)
        query[String(kSecMatchLimit)] = kSecMatchLimitOne
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
            let message = "Failed to get value from Keychain using SecItemCopyMatching with key: \(key.rawValue), got status: \(searchStatus.description)"
            servicesProvider.logger().log(level: .error, message)
            return nil
        }
    }

    func _remove<T>(key: OWKey<T>) {
        let query = query(forKey: key)

        let removeStatus = SecItemDelete(query as CFDictionary)
        if removeStatus != errSecSuccess && removeStatus != errSecItemNotFound {
            servicesProvider.logger().log(level: .error, "Failed to remove data from Keychain using SecItemDelete with key: \(key.rawValue)")
        }
    }
}

extension OWKeychain {
    func values<T>(key: OWKeychain.OWKey<T>) -> Observable<T> {
        return rx.values(key: key, defaultValue: nil)
    }

    func values<T>(key: OWKeychain.OWKey<T>, defaultValue: T? = nil) -> Observable<T> {
        return rx.values(key: key, defaultValue: defaultValue)
    }

    func setValues<T>(key: OWKeychain.OWKey<T>) -> Binder<T> {
        return rx.setValues(key: key)
    }
}

fileprivate extension Reactive where Base: OWKeychain {
    func setValues<T>(key: OWKeychain.OWKey<T>) -> Binder<T> {
        return base.rxHelper.binder(key: OWRxHelperKey<T>(key: key)) { (value) in
            base.save(value: value, forKey: key)
        }
    }

    func values<T>(key: OWKeychain.OWKey<T>, defaultValue: T? = nil) -> Observable<T> {
        return base.rxHelper.observable(key: OWRxHelperKey<T>(key: key), value: base._get(key: key), defaultValue: defaultValue)
    }
}
