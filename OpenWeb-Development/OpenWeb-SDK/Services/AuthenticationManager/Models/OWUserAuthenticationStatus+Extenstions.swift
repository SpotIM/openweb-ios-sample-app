//
//  OWUserAuthenticationStatus+Extenstions.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

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
