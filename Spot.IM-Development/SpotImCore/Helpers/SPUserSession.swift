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
    fileprivate static let servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared

    static var session: SPUserSessionType = {
        let session = loadOrCreateGuestUserSession()
        return session
    }()

    static func updateSessionUser(user: SPUser) {
        // preserving entered username for unregistered user
        session.user = user
        SPAnalyticsHolder.default.userId = user.id
        SPAnalyticsHolder.default.isUserRegistered = user.registered
        
        servicesProvider.keychain().save(value: user, forKey: OWKeychain.OWKey<SPUser>.loggedInUserSession)
    }
    
    static func updateSessionUserSSOPublisherId(_ ssoPublisherId: String) {
        session.user?.ssoPublisherId = ssoPublisherId
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
        
        let keychain = servicesProvider.keychain()
        if let authToken = session.token {
            keychain.save(value: authToken, forKey: OWKeychain.OWKey<String>.authorizationSessionToken)
        }
        if let openwebToken = session.openwebToken {
            keychain.save(value: openwebToken, forKey: OWKeychain.OWKey<String>.openwebSessionToken)
        }
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
        let keychain = servicesProvider.keychain()
        keychain.remove(key: OWKeychain.OWKey<String>.authorizationSessionToken)
        keychain.remove(key: OWKeychain.OWKey<SPUser>.loggedInUserSession)
        keychain.remove(key: OWKeychain.OWKey<[String: Bool]>.reportedCommentsSession)

        session = loadOrCreateGuestUserSession()
    }

    private static func loadOrCreateGuestUserSession() -> SPUserSessionType {
        let session = SPUserSession()
        let keychain = servicesProvider.keychain()
        
        if keychain.get(key: OWKeychain.OWKey<String>.guestSessionUserId) == nil {
            let newUuid = UUID().uuidString
            keychain.save(value: newUuid, forKey: OWKeychain.OWKey<String>.guestSessionUserId)
        }
        
        session.guid = keychain.get(key: OWKeychain.OWKey<String>.guestSessionUserId)
        session.token = keychain.get(key: OWKeychain.OWKey<String>.authorizationSessionToken)
        session.openwebToken = keychain.get(key: OWKeychain.OWKey<String>.openwebSessionToken)
        
        if let reportedComments = keychain.get(key: OWKeychain.OWKey<[String: Bool]>.reportedCommentsSession) {
            session.reportedComments = reportedComments
        }
        
        session.user = keychain.get(key: OWKeychain.OWKey<SPUser>.loggedInUserSession)

        return session
    }
    
    static func reportComment(commentId: String) {
        session.reportedComments[commentId] = true
        servicesProvider.keychain().save(value: session.reportedComments, forKey: OWKeychain.OWKey<[String: Bool]>.reportedCommentsSession)
    }
    
    static func isRegister() -> Bool {
        if let user = session.user, user.registered {
            return true
        }
        return false
    }
}

public final class SPPublicSessionInterface {
    public static func isMe(userId: String) -> Bool {
        return userId == SPUserSessionHolder.session.user?.id
    }
}

extension Notification.Name {
    public static let userDisplayNameFrozen = Notification.Name.init("im.spot.ios.session.UserDisplayNameFrozen")
}
