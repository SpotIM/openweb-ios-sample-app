//
//  SPInternalAuthenticationRequests.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 25/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

internal enum SPInternalAuthRequests: SPRequest {
    case guest
    case ssoStart
    case ssoComplete

    internal var method: HTTPMethod {
        return .post
    }

    internal var pathString: String {
        switch self {
        case .guest:        return "/user/login"
        case .ssoStart:     return "/user/sso/start"
        case .ssoComplete:  return "/user/sso/complete"
        }
    }

    internal var url: URL! {
        return URL(string: APIConstants.baseURLString.appending(pathString))
    }
}
