//
//  OWUserMentionEndpoints.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 25/02/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

enum OWUserMentionEndpoints: OWEndpoints {
    case getUsers(name: String, count: Int)

    // MARK: - HTTPMethod
    var method: OWNetworkHTTPMethod {
        switch self {
        case .getUsers: return .get
        }
    }

    // MARK: - Path
    var path: String {
        switch self {
        case .getUsers: return "/user/find-user/name"
        }
    }

    // MARK: - Parameters
    var parameters: OWNetworkParameters? {
        switch self {
        case .getUsers:
            return nil
        }
    }

    var queryParams: [Foundation.URLQueryItem]? {
        switch self {
        case .getUsers(let name, let count):
            return [Foundation.URLQueryItem(name: "name", value: name),
                    Foundation.URLQueryItem(name: "count", value: "\(count)")]
        }
    }
}

protocol OWUserMentionAPI {
    func getUsers(name: String, count: Int) -> OWNetworkResponse<OWUserMentionResponse>
}

extension OWNetworkAPI: OWUserMentionAPI {
    var userMention: OWUserMentionAPI { return self }

    func getUsers(name: String, count: Int) -> OWNetworkResponse<OWUserMentionResponse> {
        let endpoint = OWUserMentionEndpoints.getUsers(name: name, count: count)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}
