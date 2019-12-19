//
//  SPAuthenticationProvider.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 25/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

public typealias AuthCompletionHandler = (_ success: Bool, _ error: Error?) -> Void
public typealias AuthStratCompleteionHandler = (_ response: SSOStartResponse?, _ error: Error?) -> Void

public protocol SPAuthenticationProvider: class {
    func startSSO(completion: @escaping AuthStratCompleteionHandler)
    func sso(withJwtSecret secret: String, completion: @escaping AuthStratCompleteionHandler)
    
    @available(*, deprecated, message: "Use startSSO/ssoWithJwt instead")
    func startSSO(with secret: String?,
                  completion: @escaping (_ response: SSOStartResponse?, _ error: Error?) -> Void)
    
    func completeSSO(with codeB: String?, genericToken: String?,
                     completion: @escaping AuthCompletionHandler)
    
    var ssoAuthDelegate: SSOAthenticationDelegate? { get set }
}

public extension SPAuthenticationProvider {
    func startSSO(with secret: String? = nil,
                  completion: @escaping (_ response: SSOStartResponse?, _ error: Error?) -> Void) {}
}

public final class SPDefaultAuthProvider: SPAuthenticationProvider {
    
    public weak var ssoAuthDelegate: SSOAthenticationDelegate?
    private let internalAuthProvider: SPDefaultInternalAuthProvider
    private let manager: ApiManager
    public init() {
        manager = ApiManager()
        internalAuthProvider = SPDefaultInternalAuthProvider(apiManager: manager)
    }
    
    public func startSSO(completion: @escaping AuthStratCompleteionHandler) {
        internalAuthProvider.login { (token, error) in
            if let error = error {
                completion(nil, error)
            } else if let token = token {
                let newParams = SPCodeAParameters(token: token, secret: nil)
                self.getCodeA(withGuest: newParams, completion: completion)
            }
        }
    }
    
    public func sso(withJwtSecret secret: String, completion: @escaping AuthStratCompleteionHandler) {
        internalAuthProvider.login { (token, error) in
            if let error = error {
                completion(nil, error)
            } else if let token = token {
                let newParams = SPCodeAParameters(token: token, secret: secret)
                self.getCodeA(withGuest: newParams, completion: completion)
            }
        }
    }
    
    @available(*, deprecated, message: "Use startSSO/ssoWithJwt instead")
    public func startSSO(with secret: String? = nil,
                         completion: @escaping (_ response: SSOStartResponse?, _ error: Error?) -> Void) {
        
        internalAuthProvider.login { (token, error) in
            if let error = error {
                completion(nil, error)
            } else if let token = token {
                let newParams = SPCodeAParameters(token: token, secret: secret)
                self.getCodeA(withGuest: newParams, completion: completion)
            }
        }
    }

    private func getCodeA(withGuest ssoParams: SPCodeAParameters?,
                          completion: @escaping (_ response: SSOStartResponse?, _ error: Error?) -> Void) {
        guard let spotKey = SPClientSettings.main.spotKey else {
            let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
            completion(nil, SPNetworkError.custom(message))
            return
        }
        let spRequest = SPInternalAuthRequests.ssoStart
        var requestParams: [String: Any] = ["spot_id": spotKey]
                             
        if let secret = ssoParams?.secret {
            requestParams["secret"] = secret
        }
        
        var headers = HTTPHeaders.basic(with: spotKey, postId: "default")
        headers["Authorization"] = ssoParams?.token
        manager.execute(
            request: spRequest,
            parameters: requestParams,
            parser: JSONParser(),
            headers: headers
        ) { [weak self] result, response in
            guard let self = self else { return }
            
            switch result {
            case .success(let json):
                let codeA = json["code_a"] as? String
                let autocomplete = json["auto_complete"] as? Bool ?? false
                if autocomplete {
                    SPUserSessionHolder.updateSession(with: response.response)
                }
                let result = SSOStartResponse(codeA: codeA,
                                              jwtToken: ssoParams?.token,
                                              autoComplete: autocomplete,
                                              success: json["success"] as? Bool ?? false)
                if result.autoComplete {
                    self.internalAuthProvider.login { [weak self] _, error in
                        if error == nil {
                            self?.ssoAuthDelegate?.ssoFlowDidSucceed()
                            completion(result, nil)
                        } else {
                            self?.ssoAuthDelegate?.ssoFlowDidFail(with: error)
                            completion(nil, error)
                        }
                    }
                } else {
                    completion(result, nil)
                }
            case .failure(let error):
                let rawReport = RawReportModel(url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                                               parameters: requestParams,
                                               errorData: response.data,
                                               errorMessage: error.localizedDescription)
                SPDefaultFailureReporter().sendFailureReport(rawReport)
                
                completion(nil, SPNetworkError.default)
            }
        }
    }

    public func completeSSO(with codeB: String?,
                            genericToken: String? = nil,
                            completion: @escaping AuthCompletionHandler) {
        guard let spotKey = SPClientSettings.main.spotKey else {
            let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
            completion(false, SPNetworkError.custom(message))
            return
        }
        guard let codeB = codeB else {
            let message = LocalizationManager.localizedString(key: "Please provide Code B")
            completion(false, SPNetworkError.custom(message))
            return
        }
        let spRequest = SPInternalAuthRequests.ssoComplete
        let params = ["code_b": codeB]
        var headers = HTTPHeaders.basic(with: spotKey, postId: "default")
        if let token = genericToken {
            headers["Authorization"] = token
        }
        
        manager.execute(
        request: spRequest,
        parameters: params,
        parser: JSONParser(),
        headers: headers
        ) { [weak self] (result, response) in
            guard let self = self else { return }
            
            switch result {
            case .success(let json):
                let success = json["success"] as? Bool ?? false
                if success {
                    self.updateSession(response: response.response, completion: completion)
                } else {
                    let errorMessage = LocalizationManager.localizedString(key: "Authentication error")
                    let error = SPNetworkError.custom(errorMessage)
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: params,
                        errorData: response.data,
                        errorMessage: error.localizedDescription
                    )
                    SPDefaultFailureReporter().sendFailureReport(rawReport)
                    
                    self.ssoAuthDelegate?.ssoFlowDidFail(with: error)
                    completion(false, error)
                }
            case .failure(let error):
                let rawReport = RawReportModel(
                    url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                    parameters: nil,
                    errorData: response.data,
                    errorMessage: error.localizedDescription
                )
                SPDefaultFailureReporter().sendFailureReport(rawReport)
                
                self.ssoAuthDelegate?.ssoFlowDidFail(with: SPNetworkError.default)
                completion(false, SPNetworkError.default)
            }
        }
    }
    
    private func updateSession(response: HTTPURLResponse?, completion: @escaping AuthCompletionHandler) {
        SPUserSessionHolder.updateSession(with: response)
        let token = response?.allHeaderFields.authorizationHeader
        internalAuthProvider.login { [weak self] _, error in
            if error == nil {
                self?.ssoAuthDelegate?.ssoFlowDidSucceed()
                completion(token != nil && !token!.isEmpty, nil)
            } else {
                self?.ssoAuthDelegate?.ssoFlowDidFail(with: error)
                completion(false, error)
            }
        }
    }
}

private struct SPCodeAParameters {
    public init(token: String? = nil, secret: String? = nil) {
        self.token = token
        self.secret = secret
    }
    var token: String?
    var secret: String?
}

public struct SSOStartResponse {
    public var codeA: String?
    public var jwtToken: String?
    public var autoComplete: Bool = false
    public var success: Bool = false
}
