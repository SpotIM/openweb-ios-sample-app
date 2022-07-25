//
//  OWProfileEndpoint.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 20/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

enum OWProfileEndpoint: OWEndpoint {
    case createSingleUseToken
    
    // MARK: - HTTPMethod
    var method: HTTPMethod {
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
    var parameters: Parameters? {
        switch self {
        case .createSingleUseToken:
            var requestParams: Parameters = ["access_token": SPUserSessionHolder.session.token?.replacingOccurrences(of: "Bearer ", with: "")]
            if let openwebToken = SPUserSessionHolder.session.openwebToken {
                requestParams["open_web_token"] = openwebToken
            }
            return requestParams
        }
    }
}

protocol OWProfileAPI {
    func createSingleUseToken() -> OWNetworkResponse<[String: String]>
}

extension OWNetworkAPI: OWProfileAPI {
    // Access by .profile for readability
    var profile: OWProfileAPI { return self }
    
    func createSingleUseToken() -> OWNetworkResponse<[String: String]> {
        let endpoint = OWProfileEndpoint.createSingleUseToken
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}
