//
//  OWKeychain.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/06/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

protocol OWKeychainProtocol {
    
}

class OWKeychain : OWKeychainProtocol {
    fileprivate struct Metrics {
        static let accountAttr = "com.open-web.sdk"
    }
    
    enum Value<T>: String {
        case guestSessionUserId = "session.guest.userId"
        case loggedInUserSession = "session.user"
        case authorizatioSessionToken = "session.authorization.token"
        case openwebSessionToken = "session.openweb.toekn"
        case reportedCommentsSession = "session.reported.comments"
    }
    
//    fileprivate extension Value {
//        func getValue(): T? {
//
//        }
//
//        func set(velue: T) {
//
//        }
//    }
}

fileprivate extension OWKeychain {
    func save(data: Data) throws {
        let query: [String: Any] = [
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? Metrics.accountAttr,
            kSecAttrAccount as String: Metrics.accountAttr,
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: data
        ]
        
    }
}
