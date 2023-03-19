//
//  OWAuthenticationEndpoints.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 25/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

enum OWAuthenticationEndpoints: OWEndpoints {
    case login
    case ssoStart
    case ssoComplete(codeB: String)
    case logout
    case user

    // MARK: - HTTPMethod
    var method: OWNetworkHTTPMethod {
        switch self {
        case .login, .ssoStart, .ssoComplete, .logout, .user:
            return .post
        }
    }

    // MARK: - Path
    var path: String {
        switch self {
        case .login:        return "/user/login"
        case .ssoStart:     return "/user/sso/start"
        case .ssoComplete:  return "/user/sso/complete"
        case .logout:       return "/user/logout"
        case .user:         return "/user/data"
        }
    }

    // MARK: - Parameters
    var parameters: OWNetworkParameters? {
        switch self {
        case .login:
            return nil
        case .ssoStart:
//            let spotKey = SPClientSettings.main.spotKey
//            var requestParams: [String: Any] = ["spot_id": spotKey]
//            requestParams["secret"] = secret
//            return requestParams
//            return ["secret": secret]
            return nil
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
    func login() -> OWNetworkResponse<SPUser>
    func ssoStart() -> OWNetworkResponse<OWSSOStartResponse>
    func ssoComplete(codeB: String) -> OWNetworkResponse<OWSSOCompletionResponse>
    func logout() -> OWNetworkResponse<EmptyDecodable>
    func user() -> OWNetworkResponse<SPUser>
}

extension OWNetworkAPI: OWAuthenticationAPI {
    // Access by .authentication for readability
    var authentication: OWAuthenticationAPI { return self }

    func login() -> OWNetworkResponse<SPUser> {
        let endpoint = OWAuthenticationEndpoints.login
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func ssoStart() -> OWNetworkResponse<OWSSOStartResponse> {
        let endpoint = OWAuthenticationEndpoints.ssoStart
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func ssoComplete(codeB: String) -> OWNetworkResponse<OWSSOCompletionResponse> {
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
