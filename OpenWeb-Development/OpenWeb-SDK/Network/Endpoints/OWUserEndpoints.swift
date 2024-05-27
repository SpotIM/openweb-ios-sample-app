//
//  OWUserEndpoints.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 28/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

enum OWUserEndpoints: OWEndpoints {
    case userData
    case mute(userId: String)
    case getUsers(name: String, count: Int)

    // MARK: - HTTPMethod
    var method: OWNetworkHTTPMethod {
        switch self {
        case .mute, .userData:
            return .post
        case .getUsers:
            return .get
        }
    }

    // MARK: - Path
    var path: String {
        switch self {
        case .userData: return "/user/data"
        case .mute:     return "/user/mute-user"
        case .getUsers: return "/user/find-user/name"
        }
    }

    // MARK: - Parameters
    var parameters: OWNetworkParameters? {
        switch self {
        case .mute(let userId):
            return ["user_id": userId]
        case .userData:
            return nil
        case .getUsers:
            return nil
        }
    }

    var queryParams: [Foundation.URLQueryItem]? {
        switch self {
        case .getUsers(let name, let count):
            return [Foundation.URLQueryItem(name: "name", value: name),
                    Foundation.URLQueryItem(name: "count", value: "\(count)")]
        case .userData, .mute:
            return nil
        }
    }
}

protocol OWUserAPI {
    func userData() -> OWNetworkResponse<SPUser>
    func mute(userId: String) -> OWNetworkResponse<OWNetworkEmpty>
    func getUsers(name: String, count: Int) -> OWNetworkResponse<OWUserMentionResponse>
}

extension OWNetworkAPI: OWUserAPI {
    // Access by .user for readability
    var user: OWUserAPI { return self }

    func userData() -> OWNetworkResponse<SPUser> {
        let endpoint = OWUserEndpoints.userData
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func mute(userId: String) -> OWNetworkResponse<OWNetworkEmpty> {
        let endpoint = OWUserEndpoints.mute(userId: userId)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func getUsers(name: String, count: Int) -> OWNetworkResponse<OWUserMentionResponse> {
        let endpoint = OWUserEndpoints.getUsers(name: name, count: count)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}
