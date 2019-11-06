//
//  SPUserSession.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 08/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal protocol SPUserSessionType {
    
    var user: SPUser? { get set }
    var userId: String? { get set }
    var token: String? { get set }
    
}

final internal class SPUserSession: SPUserSessionType {
    
    internal var user: SPUser?
    internal var userId: String?
    internal var token: String?
    
}

internal class SPUserSessionHolder {

    static var session: SPUserSessionType = {
        let session = loadOrCreateGuestUserSession()
        return session
    }()

    static func updateSessionUser(user: SPUser?) {
        session.user = user
        SPAnalyticsHolder.default.userId = user?.id
        SPAnalyticsHolder.default.isUserRegistered = user?.registered ?? false
    }
    
    static func updateSession(with headers: [AnyHashable: Any]?, forced: Bool = false) {
        if forced {
            session.userId = headers?.userIdHeader
            session.token = headers?.authorizationHeader
        } else {
            let userId = headers?.userIdHeader ?? session.userId
            let token = headers?.authorizationHeader ?? session.token
            session.userId = userId
            session.token = token
        }
        UserDefaults.standard.setValue(session.userId, forKey: .guestSessionUserIdKey)
        UserDefaults.standard.setValue(session.token, forKey: .guestSessionTokenKey)
    }

    static func resetUserSession() {
        UserDefaults.standard.removeObject(forKey: .guestSessionUserIdKey)
        UserDefaults.standard.removeObject(forKey: .guestSessionTokenKey)
        session = loadOrCreateGuestUserSession()
    }

    private static func loadOrCreateGuestUserSession() -> SPUserSessionType {
        let session = SPUserSession()
        session.userId = UserDefaults.standard.string(forKey: .guestSessionUserIdKey)
        session.token = UserDefaults.standard.string(forKey: .guestSessionTokenKey)
    
        return session
    }
}

private extension String {
    static let guestSessionUserIdKey = "session.guest.userId"
    static let guestSessionTokenKey = "session.guest.token"
}

// TODO: (Fedin) remove this before release
// FIXME: (Fedin) seriously!
public final class SPPublicSessionInterface {
    public static func resetUser() {
        SPUserSessionHolder.resetUserSession()
    }
    
    public static func isMe(userId: String) -> Bool {
        return userId == SPUserSessionHolder.session.userId
    }
}
