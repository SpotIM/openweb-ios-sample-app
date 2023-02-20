//
//  OWKeychainMigrationService.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/06/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

// Remove this migration service file within half a year from now

protocol OWKeychainMigrationServicing {
    func migrateToKeychainIfNeeded()
}

class OWKeychainMigrationService: OWKeychainMigrationServicing {
    fileprivate let deletionQueue: DispatchQueue
    fileprivate let deletionUserDefaults: UserDefaults
    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate let decoder: JSONDecoder

    fileprivate enum OldDataKeys: String, CaseIterable {
        case guestSessionUserId = "session.guest.userId"
        case authorizatioSessionToken = "session.authorization.token"
        case openwebSessionToken = "session.openweb.toekn"
        case userSession = "session.user"
        case reportedCommentsSession = "session.reportedComments"
        // Those we should just remove (keys were recently changed)
        case oldGuestSessionToken = "session.guest.token"
        case oldOpenwebSessionToken = "openweb.session.toekn"
    }

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         deletionQueue: DispatchQueue = DispatchQueue(label: "OpenWebSDKRemoveOldDataQueue", qos: .background),
         deletionUserDefaults: UserDefaults = UserDefaults.standard,
         decoder: JSONDecoder = JSONDecoder()) {
        self.servicesProvider = servicesProvider
        self.deletionQueue = deletionQueue
        self.deletionUserDefaults = deletionUserDefaults
        self.decoder = decoder
    }

    func migrateToKeychainIfNeeded() {
        let keychain = servicesProvider.keychain()
        let logger = servicesProvider.logger()
        let isDataMigrated = keychain.get(key: OWKeychain.OWKey<Bool>.isMigratedToKeychain) ?? false

        if (!isDataMigrated) {
            logger.log(level: .verbose, "Performing sensitive data migration from User Defaults to Keychain")
            migratePersistentDataToKeychain()
            keychain.save(value: true, forKey: OWKeychain.OWKey<Bool>.isMigratedToKeychain)
            logger.log(level: .verbose, "Finished migration from User Defaults to Keychain")
            removeOldData()
        }
    }
}

fileprivate extension OWKeychainMigrationService {
    func migratePersistentDataToKeychain() {
        let keychain = servicesProvider.keychain()

        // One by one as there is no way to know the value type from the old keys

        // We recently changed the key for the auth token, so trying to get it from the newer key and if there is no value there, from the old key
        var authToken = deletionUserDefaults.string(forKey: OldDataKeys.authorizatioSessionToken.rawValue)
        if authToken == nil {
            authToken = deletionUserDefaults.string(forKey: OldDataKeys.oldGuestSessionToken.rawValue)
        }
        if let token = authToken {
            keychain.save(value: token, forKey: OWKeychain.OWKey<String>.authorizationSessionToken)
        }

        // We recently changed the key for the open web token, so trying to get it from the newer key and if there is no value there, from the old key
        var openwebToken = deletionUserDefaults.string(forKey: OldDataKeys.openwebSessionToken.rawValue)
        if openwebToken == nil {
            openwebToken = deletionUserDefaults.string(forKey: OldDataKeys.oldOpenwebSessionToken.rawValue)
        }
        if let token = openwebToken {
            keychain.save(value: token, forKey: OWKeychain.OWKey<String>.openwebSessionToken)
        }

        // User Id
        if let userId = deletionUserDefaults.string(forKey: OldDataKeys.guestSessionUserId.rawValue) {
            keychain.save(value: userId, forKey: OWKeychain.OWKey<String>.guestSessionUserId)
        }

        // User
        if let userData = deletionUserDefaults.object(forKey: OldDataKeys.userSession.rawValue) as? Data,
           let user = try? decoder.decode(SPUser.self, from: userData) {
            keychain.save(value: user, forKey: OWKeychain.OWKey<SPUser>.loggedInUserSession)
        }

        // Reported comments
        if let reportedComments = deletionUserDefaults.dictionary(forKey: OldDataKeys.reportedCommentsSession.rawValue) as? [String: Bool] {
            keychain.save(value: reportedComments, forKey: OWKeychain.OWKey<[String: Bool]>.reportedCommentsSession)
        }
    }

    func removeOldData() {
        // Done on a background queue as we don't need it to happen immediately
        deletionQueue.async { [weak self] in
            guard let self = self else { return }
            for key in OldDataKeys.allCases {
                self.deletionUserDefaults.removeObject(forKey: key.rawValue)
            }
            self.servicesProvider.logger().log(level: .verbose, "Removed sensitive data from User Defaults")
        }
    }
}
