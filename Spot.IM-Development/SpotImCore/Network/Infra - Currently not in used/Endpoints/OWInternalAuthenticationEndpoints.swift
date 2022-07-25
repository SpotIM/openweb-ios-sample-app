//
//  OWInternalAuthenticationEndpoint.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 25/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

enum OWInternalAuthenticationEndpoints: OWEndpoints {
    case guest
    case ssoStart(secret: String?, token: String?)
    case ssoComplete(codeB: String)
    case logout
    case user
    
    // MARK: - HTTPMethod
    var method: HTTPMethod {
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
    var parameters: Parameters? {
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
    
    var additionalMiddlewares: [OWRequestMiddleware]? {
        switch self {
        case .ssoStart(let secret, let token):
            return [OWHTTPAuthHeaderRequestMiddleware(token: token)]
        default: return nil
        }
    }
}

protocol OWInternalAuthenticationAPI {
    func loginGuest() -> OWNetworkResponse<SPUser>
    func ssoStart(secret: String?, token: String?) -> OWNetworkResponse<SSOStartResponseInternal>
    func ssoComplete(codeB: String) -> OWNetworkResponse<SSOCompleteResponseInternal>
    func logout() -> OWNetworkResponse<EmptyDecodable>
    func user() -> OWNetworkResponse<SPUser>
}

extension OWNetworkAPI: OWInternalAuthenticationAPI {
    // Access by .internalAuthentication for readability
    var internalAuthentication: OWInternalAuthenticationAPI { return self }
    
    func loginGuest() -> OWNetworkResponse<SPUser> {
        let endpoint = OWInternalAuthenticationEndpoints.guest
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
    
    func ssoStart(secret: String?, token: String?) -> OWNetworkResponse<SSOStartResponseInternal> {
        let endpoint = OWInternalAuthenticationEndpoints.ssoStart(secret: secret, token: token)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
    
    func ssoComplete(codeB: String) -> OWNetworkResponse<SSOCompleteResponseInternal> {
        let endpoint = OWInternalAuthenticationEndpoints.ssoComplete(codeB: codeB)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
    
    func logout() -> OWNetworkResponse<EmptyDecodable> {
        let endpoint = OWInternalAuthenticationEndpoints.logout
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
    
    func user() -> OWNetworkResponse<SPUser> {
        let endpoint = OWInternalAuthenticationEndpoints.user
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}

class OWHTTPAuthHeaderRequestMiddleware: OWRequestMiddleware {
    private var token = SPUserSessionHolder.session.token
    init(token: String?) {
        self.token = token ?? SPUserSessionHolder.session.token
    }
    func process(request: URLRequest) -> URLRequest {
        var newRequest = request
        newRequest.setValue(self.token, forHTTPHeaderField: OWHTTPHeaderName.authorization)
        return newRequest
    }
}
