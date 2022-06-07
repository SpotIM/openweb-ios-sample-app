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
    
    fileprivate enum OldDataKeys: String, CaseIterable {
        case guestSessionUserId = "session.guest.userId"
        case authorizatioSessionToken = "session.authorization.token"
        case openwebSessionToken = "session.openweb.toekn"
        case userSession = "session.user"
        case reportedCommentsSession = "session.reportedComments"
    }
    
    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         deletionQueue: DispatchQueue = DispatchQueue(label: "OpenWebSDKRemoveOldDataQueue", qos: .background),
         deletionUserDefaults: UserDefaults = UserDefaults.standard) {
        self.servicesProvider = servicesProvider
        self.deletionQueue = deletionQueue
        self.deletionUserDefaults = deletionUserDefaults
    }
    
    func migrateToKeychainIfNeeded() {
        let keychain = servicesProvider.keychain()
        let logger = servicesProvider.logger()
        let isDataMigrated = keychain.get(key: OWKeychain.OWKeychainKey<Bool>.isMigratedToKeychain) ?? false
        
        if (!isDataMigrated) {
            logger.log(level: .verbose, "Performing sensitive data migration from User Defaults to Keychain")
            migratePersistentDataToKeychain()
            keychain.save(value: true, forKey: OWKeychain.OWKeychainKey<Bool>.isMigratedToKeychain)
            logger.log(level: .verbose, "Finished migration from User Defaults to Keychain")
            removeOldData()
        }
    }
}

fileprivate extension OWKeychainMigrationService {
    func migratePersistentDataToKeychain() {
        // One by one as the keys are not the same and also some of the old keys are here just for deletion
        // TODO: Complete
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
