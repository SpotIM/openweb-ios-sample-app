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
    var openwebToken: String? { get set }
    var displayNameFrozen: Bool { get set }
    var reportedComments: [String:Bool] { get set }
}

final internal class SPUserSession: SPUserSessionType {

    internal var user: SPUser?
    internal var guid: String?
    internal var token: String?
    internal var openwebToken: String?
    var displayNameFrozen: Bool = false
    var reportedComments: [String:Bool] = [:]

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
            SPDefaultFailureReporter.shared.sendNetworkFailureReport(rawReport)
        }
        
        if forced {
            session.token = headers?.authorizationHeader
            session.openwebToken = headers?.openwebTokenHeader
        } else {
            session.token = headers?.authorizationHeader ?? session.token
            session.openwebToken = headers?.openwebTokenHeader ?? session.openwebToken
        }
        UserDefaults.standard.setValue(session.token, forKey: .guestSessionTokenKey)
        UserDefaults.standard.setValue(session.openwebToken, forKey: .openwebSessionToken)
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
        UserDefaults.standard.removeObject(forKey: .reportedCommentsKey)
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
        session.openwebToken = UserDefaults.standard.string(forKey: .openwebSessionToken)
        
        if let reportedComments = UserDefaults.standard.dictionary(forKey: .reportedCommentsKey) as? [String:Bool] {
            session.reportedComments = reportedComments
        }
        
        if let savedUser = UserDefaults.standard.object(forKey: .userSessionKey) as? Data {
            let decoder = JSONDecoder()
            if let user = try? decoder.decode(SPUser.self, from: savedUser) {
                session.user = user
            }
        }

        return session
    }
    
    static func reportComment(commentId: String) {
        session.reportedComments[commentId] = true
        UserDefaults.standard.set(session.reportedComments, forKey: .reportedCommentsKey)
    }
    
    static func isRegister() -> Bool {
        if let user = session.user, user.registered {
            return true
        }
        return false
    }
}

private extension String {
    static let guestSessionUserIdKey = "session.guest.userId"
    static let guestSessionTokenKey = "session.guest.token"
    static let openwebSessionToken = "openweb.session.toekn"
    static let userSessionKey = "session.user"
    static let reportedCommentsKey = "session.reportedComments"
}

public final class SPPublicSessionInterface {
    public static func isMe(userId: String) -> Bool {
        return userId == SPUserSessionHolder.session.user?.id
    }
}

extension Notification.Name {
    public static let userDisplayNameFrozen = Notification.Name.init("im.spot.ios.session.UserDisplayNameFrozen")
}
