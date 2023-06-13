//
//  OWUserAuthenticationStatus+Extenstions.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
extension OWUserAuthenticationStatus: Equatable {
    public static func == (lhs: OWUserAuthenticationStatus, rhs: OWUserAuthenticationStatus) -> Bool {
        switch (lhs, rhs) {
        case (.notAutenticated, .notAutenticated):
            return true
        case (.guest, .guest):
            return true
        case (let .ssoLoggedIn(lhsId), let .ssoLoggedIn(rhsId)):
            return lhsId == rhsId
        default:
            return false
        }
    }
}
#else
extension OWUserAuthenticationStatus: Equatable {
    static func == (lhs: OWUserAuthenticationStatus, rhs: OWUserAuthenticationStatus) -> Bool {
        switch (lhs, rhs) {
        case (.notAutenticated, .notAutenticated):
            return true
        case (.guest, .guest):
            return true
        case (let .ssoLoggedIn(lhsId), let .ssoLoggedIn(rhsId)):
            return lhsId == rhsId
        default:
            return false
        }
    }
}
#endif
