//
//  OWInternalUserAuthenticationStatus.swift
//  SpotImCore
//
//  Created by Alon Haiut on 12/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWInternalUserAuthenticationStatus {
    case notAutenticated
    case guest(userId: String)
    case ssoLoggedIn(userId: String)
    case ssoRecovering(userId: String)
    case ssoRecoveredSuccessfully(userId: String)
    case ssoFailedRecover(userId: String)
}

extension OWInternalUserAuthenticationStatus {
    var authenticationLevelAvailability: OWAuthenticationLevelAvailability {
        switch self {
        case .notAutenticated:
            return .level(.notAutenticated)
        case .guest(_):
            return .level(.guest)
        case .ssoLoggedIn(_):
            return .level(.loggedIn)
        default:
            return .pending
        }
    }

    func toOWUserAuthenticationStatus() -> OWUserAuthenticationStatus? {
        switch self {
        case .guest(_):
            return .guest
        case .ssoLoggedIn(let userId):
            return .ssoLoggedIn(userId: userId)
        default:
            return nil
        }
    }
}
