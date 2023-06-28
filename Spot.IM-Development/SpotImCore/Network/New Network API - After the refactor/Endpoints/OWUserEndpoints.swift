//
//  OWUserEndpoints.swift
//  SpotImCore
//
//  Created by Alon Shprung on 28/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWUserEndpoints: OWEndpoints {
    case userData
    case mute(userId: String)

    // MARK: - HTTPMethod
    var method: OWNetworkHTTPMethod {
        switch self {
        case .mute, .userData:
            return .post
        }
    }

    // MARK: - Path
    var path: String {
        switch self {
        case .userData: return "user/data"
        case .mute:     return "/user/mute-user"
        }
    }

    // MARK: - Parameters
    var parameters: OWNetworkParameters? {
        switch self {
        case .mute(let userId):
            return ["user_id": userId]
        case .userData:
            return nil
        }
    }
}

protocol OWUserAPI {
    func userData() -> OWNetworkResponse<SPUser>
    func mute(userId: String) -> OWNetworkResponse<EmptyDecodable>
}

extension OWNetworkAPI: OWUserAPI {
    // Access by .user for readability
    var user: OWUserAPI { return self }

    func userData() -> OWNetworkResponse<SPUser> {
        let endpoint = OWUserEndpoints.userData
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func mute(userId: String) -> OWNetworkResponse<EmptyDecodable> {
        let endpoint = OWUserEndpoints.mute(userId: userId)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}
