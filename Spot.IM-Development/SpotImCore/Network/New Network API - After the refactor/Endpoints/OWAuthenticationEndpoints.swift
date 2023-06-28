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
    case ssoStart(secret: String)
    case ssoComplete(codeB: String)
    case logout
    case userData

    // MARK: - HTTPMethod
    var method: OWNetworkHTTPMethod {
        switch self {
        case .login, .ssoStart, .ssoComplete, .logout, .userData:
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
        case .userData:         return "/user/data"
        }
    }

    // MARK: - Parameters
    var parameters: OWNetworkParameters? {
        switch self {
        case .login:
            return nil
        case .ssoStart(let secret):
            return ["secret": secret]
        case .ssoComplete(let codeB):
            return ["code_b": codeB]
        case .logout:
            return nil
        case .userData:
            return nil
        }
    }
}

protocol OWAuthenticationAPI {
    func login() -> OWNetworkResponse<SPUser>
    func ssoStart(secret: String) -> OWNetworkResponse<OWSSOStartResponse>
    func ssoComplete(codeB: String) -> OWNetworkResponse<OWSSOCompletionResponse>
    func logout() -> OWNetworkResponse<EmptyDecodable>
    func userData() -> OWNetworkResponse<SPUser>
}

extension OWNetworkAPI: OWAuthenticationAPI {
    // Access by .authentication for readability
    var authentication: OWAuthenticationAPI { return self }

    func login() -> OWNetworkResponse<SPUser> {
        let endpoint = OWAuthenticationEndpoints.login
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func ssoStart(secret: String) -> OWNetworkResponse<OWSSOStartResponse> {
        let endpoint = OWAuthenticationEndpoints.ssoStart(secret: secret)
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

    func userData() -> OWNetworkResponse<SPUser> {
        let endpoint = OWAuthenticationEndpoints.userData
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}
