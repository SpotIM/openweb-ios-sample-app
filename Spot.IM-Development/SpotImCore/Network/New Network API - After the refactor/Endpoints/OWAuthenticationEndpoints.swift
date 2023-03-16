//
//  OWAuthenticationEndpoints.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 25/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

enum OWAuthenticationEndpoints: OWEndpoints {
    case guest
    case ssoStart(secret: String?, token: String?)
    case ssoComplete(codeB: String)
    case logout
    case user

    // MARK: - HTTPMethod
    var method: OWNetworkHTTPMethod {
        switch self {
        case .guest, .ssoStart, .ssoComplete, .logout, .user:
            return .post
        }
    }

    // MARK: - Path
    var path: String {
        switch self {
        case .guest:        return "/user/login"
        case .ssoStart:     return "/user/sso/start"
        case .ssoComplete:  return "/user/sso/complete"
        case .logout:       return "/user/logout"
        case .user:         return "/user/data"
        }
    }

    // MARK: - Parameters
    var parameters: OWNetworkParameters? {
        switch self {
        case .guest:
            return nil
        case .ssoStart(let secret, let token):
            let spotKey = SPClientSettings.main.spotKey
            var requestParams: [String: Any] = ["spot_id": spotKey]
            if let secret = secret {
                requestParams["secret"] = secret
            }
            return requestParams
        case .ssoComplete(let codeB):
            return ["code_b": codeB]
        case .logout:
            return nil
        case .user:
            return nil
        }
    }
}

protocol OWAuthenticationAPI {
    func loginGuest() -> OWNetworkResponse<SPUser>
    func ssoStart(secret: String?, token: String?) -> OWNetworkResponse<SSOStartResponseInternal>
    func ssoComplete(codeB: String) -> OWNetworkResponse<SSOCompleteResponseInternal>
    func logout() -> OWNetworkResponse<EmptyDecodable>
    func user() -> OWNetworkResponse<SPUser>
}

extension OWNetworkAPI: OWAuthenticationAPI {
    // Access by .authentication for readability
    var authentication: OWAuthenticationAPI { return self }

    func loginGuest() -> OWNetworkResponse<SPUser> {
        let endpoint = OWAuthenticationEndpoints.guest
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func ssoStart(secret: String?, token: String?) -> OWNetworkResponse<SSOStartResponseInternal> {
        let endpoint = OWAuthenticationEndpoints.ssoStart(secret: secret, token: token)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func ssoComplete(codeB: String) -> OWNetworkResponse<SSOCompleteResponseInternal> {
        let endpoint = OWAuthenticationEndpoints.ssoComplete(codeB: codeB)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func logout() -> OWNetworkResponse<EmptyDecodable> {
        let endpoint = OWAuthenticationEndpoints.logout
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func user() -> OWNetworkResponse<SPUser> {
        let endpoint = OWAuthenticationEndpoints.user
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}
