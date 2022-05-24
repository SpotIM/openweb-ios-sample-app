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
            defaults.set(encoded, forKey: .userSession)
        }
    }

    static func updateSession(with response: HTTPURLResponse?, forced: Bool = false) {
        let headers = response?.allHeaderFields
        if let serverGuid = headers?.guidHeader, serverGuid != session.guid, let url = response?.url {
            let rawReport = RawReportModel(
                url: url.absoluteString,
                parameters: nil,
                errorData: nil,
                errorMessage: "My GUID is: \(String(describing: session.guid)), but the server returned \(serverGuid)"
                           )
            SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
        }
        
        if forced {
            session.token = headers?.authorizationHeader
            session.openwebToken = headers?.openwebTokenHeader
        } else {
            session.token = headers?.authorizationHeader ?? session.token
            session.openwebToken = headers?.openwebTokenHeader ?? session.openwebToken
        }
        UserDefaults.standard.setValue(session.token, forKey: .authorizatioSessionToken)
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
        UserDefaults.standard.removeObject(forKey: .authorizatioSessionToken)
        UserDefaults.standard.removeObject(forKey: .userSession)
        UserDefaults.standard.removeObject(forKey: .reportedCommentsSession)
        session = loadOrCreateGuestUserSession()
    }

    private static func loadOrCreateGuestUserSession() -> SPUserSessionType {
        let session = SPUserSession()
        if UserDefaults.standard.string(forKey: .guestSessionUserId) == nil {
            let newUuid = UUID().uuidString
            UserDefaults.standard.set(newUuid, forKey: .guestSessionUserId)
        }
        
        session.guid = UserDefaults.standard.string(forKey: .guestSessionUserId)
        session.token = UserDefaults.standard.string(forKey: .authorizatioSessionToken)
        session.openwebToken = UserDefaults.standard.string(forKey: .openwebSessionToken)
        
        if let reportedComments = UserDefaults.standard.dictionary(forKey: .reportedCommentsSession) as? [String:Bool] {
            session.reportedComments = reportedComments
        }
        
        if let savedUser = UserDefaults.standard.object(forKey: .userSession) as? Data {
            let decoder = JSONDecoder()
            if let user = try? decoder.decode(SPUser.self, from: savedUser) {
                session.user = user
            }
        }

        return session
    }
    
    static func reportComment(commentId: String) {
        session.reportedComments[commentId] = true
        UserDefaults.standard.set(session.reportedComments, forKey: .reportedCommentsSession)
    }
    
    static func isRegister() -> Bool {
        if let user = session.user, user.registered {
            return true
        }
        return false
    }
}

private extension String {
    static let guestSessionUserId = "session.guest.userId"
    static let authorizatioSessionToken = "session.authorization.token"
    static let openwebSessionToken = "session.openweb.toekn"
    static let userSession = "session.user"
    static let reportedCommentsSession = "session.reportedComments"
}

public final class SPPublicSessionInterface {
    public static func isMe(userId: String) -> Bool {
        return userId == SPUserSessionHolder.session.user?.id
    }
}

extension Notification.Name {
    public static let userDisplayNameFrozen = Notification.Name.init("im.spot.ios.session.UserDisplayNameFrozen")
}
