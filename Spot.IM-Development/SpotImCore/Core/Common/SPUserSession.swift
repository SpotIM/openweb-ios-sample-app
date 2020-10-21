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
    var guid: String? { get set }
    var token: String? { get set }
    var displayNameFrozen: Bool { get set }
}

final internal class SPUserSession: SPUserSessionType {

    internal var user: SPUser?
    internal var guid: String?
    internal var token: String?
    var displayNameFrozen: Bool = false

}

internal class SPUserSessionHolder {

    static var session: SPUserSessionType = {
        let session = loadOrCreateGuestUserSession()
        return session
    }()

    static func updateSessionUser(user: SPUser?) {
        // preserving entered username for unregistered user
        session.user = user
        SPAnalyticsHolder.default.userId = user?.id
        SPAnalyticsHolder.default.isUserRegistered = user?.registered ?? false
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: .userSessionKey)
        }
    }

    static func updateSession(with response: HTTPURLResponse?, forced: Bool = false) {
        let headers = response?.allHeaderFields
        if let serverGuid = headers?.userIdHeader, serverGuid != session.guid, let url = response?.url {
            let rawReport = RawReportModel(
                url: url.absoluteString,
                parameters: nil,
                errorData: nil,
                errorMessage: "My GUID is: \(String(describing: session.guid)), but the server returned \(serverGuid)"
                           )
            SPDefaultFailureReporter.shared.sendFailureReport(rawReport)
        }
        
        if forced {
            session.token = headers?.authorizationHeader
        } else {
            let token = headers?.authorizationHeader ?? session.token
            session.token = token
        }
        UserDefaults.standard.setValue(session.token, forKey: .guestSessionTokenKey)
    }

    static func update(displayName: String?) {
        guard let displayName = displayName else { return }
        session.user?.displayName = displayName
    }

    static func freezeDisplayNameIfNeeded() {
        guard session.user?.registered == false else { return }
        session.displayNameFrozen = true
        let userInfo = session.user == nil ? nil : ["user" : session.user!]
        NotificationCenter.default.post(name: .userDisplayNameFrozen, object: nil, userInfo: userInfo)
    }

    static var displayNameFrozen: Bool { session.displayNameFrozen }

    static func resetUserSession() {
        UserDefaults.standard.removeObject(forKey: .guestSessionTokenKey)
        UserDefaults.standard.removeObject(forKey: .userSessionKey)
        session = loadOrCreateGuestUserSession()
    }

    private static func loadOrCreateGuestUserSession() -> SPUserSessionType {
        let session = SPUserSession()
        if UserDefaults.standard.string(forKey: .guestSessionUserIdKey) == nil {
            let newUuid = UUID().uuidString
            UserDefaults.standard.set(newUuid, forKey: .guestSessionUserIdKey)
        }
        
        session.guid = UserDefaults.standard.string(forKey: .guestSessionUserIdKey)
        session.token = UserDefaults.standard.string(forKey: .guestSessionTokenKey)
        if let savedUser = UserDefaults.standard.object(forKey: .userSessionKey) as? Data {
            let decoder = JSONDecoder()
            if let user = try? decoder.decode(SPUser.self, from: savedUser) {
                session.user = user
            }
        }

        return session
    }
}

private extension String {
    static let guestSessionUserIdKey = "session.guest.userId"
    static let guestSessionTokenKey = "session.guest.token"
    static let userSessionKey = "session.user"
}

public final class SPPublicSessionInterface {
    public static func isMe(userId: String) -> Bool {
        return userId == SPUserSessionHolder.session.user?.id
    }
}

extension Notification.Name {
    public static let userDisplayNameFrozen = Notification.Name.init("im.spot.ios.session.UserDisplayNameFrozen")
}
