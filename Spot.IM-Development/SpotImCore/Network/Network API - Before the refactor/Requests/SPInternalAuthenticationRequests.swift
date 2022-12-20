//
//  SPInternalAuthenticationRequests.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 25/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal enum SPInternalAuthRequests: SPRequest {
    case guest
    case ssoStart
    case ssoComplete
    case logout
    case user

    internal var method: HTTPMethod {
        return .post
    }

    internal var pathString: String {
        switch self {
        case .guest:        return "/user/login"
        case .ssoStart:     return "/user/sso/start"
        case .ssoComplete:  return "/user/sso/complete"
        case .logout:       return "/user/logout"
        case .user:         return "/user/data"
        }
    }

    internal var url: URL! {
        return URL(string: APIConstants.baseURLString.appending(pathString))
    }
}
