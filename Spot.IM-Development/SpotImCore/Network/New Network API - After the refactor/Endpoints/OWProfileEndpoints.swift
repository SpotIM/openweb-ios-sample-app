//
//  OWProfileEndpoint.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 20/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

enum OWProfileEndpoints: OWEndpoints {
    case createSingleUseToken

    // MARK: - HTTPMethod
    var method: OWNetworkHTTPMethod {
        switch self {
        case .createSingleUseToken:
            return .post
        }
    }

    // MARK: - Path
    var path: String {
        switch self {
        case .createSingleUseToken:
            return "/profile/create-single-use-token"
        }
    }

    // MARK: - Parameters
    var parameters: OWNetworkParameters? {
        switch self {
        case .createSingleUseToken:
            let networkCredentials = OWSharedServicesProvider.shared.authenticationManager().networkCredentials
            let accessToken = networkCredentials.authorization
            let owToken = networkCredentials.openwebToken
            var requestParams: OWNetworkParameters = ["access_token": accessToken?.replacingOccurrences(of: "Bearer ", with: "")]
            if let owToken = owToken {
                requestParams["open_web_token"] = owToken
            }
            return requestParams
        }
    }
}

protocol OWProfileAPI {
    func createSingleUseToken() -> OWNetworkResponse<OWSingleUseTokenResponse>
}

extension OWNetworkAPI: OWProfileAPI {
    // Access by .profile for readability
    var profile: OWProfileAPI { return self }

    func createSingleUseToken() -> OWNetworkResponse<OWSingleUseTokenResponse> {
        let endpoint = OWProfileEndpoints.createSingleUseToken
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}
