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

public protocol SPAuthenticationProvider: class {
    
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
    
    public init() {}

    public func startSSO(with secret: String? = nil,
                         completion: @escaping (_ response: SSOStartResponse?, _ error: Error?) -> Void) {
        
        SPDefaultInternalAuthProvider.login { (token, error) in
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
        guard let spotKey = SPClientSettings.spotKey else {
            let message = NSLocalizedString("Please provide Spot Key",
                                            comment: "Spot Key not set by client")
            completion(nil, SPNetworkError.custom(message))
            return
        }
        let spRequest = SPInternalAuthRequests.ssoStart
        var requestParams = ["spot_id": spotKey]
                             
        if let secret = ssoParams?.secret {
            requestParams["secret"] = secret
        }
        
        var headers = HTTPHeaders.unauthorized(with: spotKey, postId: "default")
        headers["Authorization"] = ssoParams?.token
        Alamofire.request(spRequest.url,
                          method: spRequest.method,
                          parameters: requestParams as Parameters,
                          encoding: APIConstants.encoding,
                          headers: headers)
            .validate()
            .responseJSON { [weak self] (response) in
                switch response.result {
                case .success(let json):
                    let dict = json as? NSDictionary
                    let codeA = dict?["code_a"] as? String
                    let autocomplete = dict?["auto_complete"] as? Bool ?? false
                    if autocomplete {
                        SPUserSessionHolder.updateSession(with: response.response?.allHeaderFields)
                    }
                    let result = SSOStartResponse(codeA: codeA,
                                                  jwtToken: ssoParams?.token,
                                                  autoComplete: autocomplete,
                                                  success: dict?["success"] as? Bool ?? false)
                    if result.autoComplete {
                        SPDefaultInternalAuthProvider.login { _, error in
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
        guard let spotKey = SPClientSettings.spotKey else {
            let message = NSLocalizedString("Please provide Spot Key",
                                            comment: "Spot Key not set by client")
            completion(false, SPNetworkError.custom(message))
            return
        }
        guard let codeB = codeB else {
            let message = NSLocalizedString("Please provide Code B",
                                            comment: "Authentication error")
            completion(false, SPNetworkError.custom(message))
            return
        }
        let spRequest = SPInternalAuthRequests.ssoComplete
        let params = ["code_b": codeB]
        var headers = HTTPHeaders.unauthorized(with: spotKey, postId: "default")
        if let token = genericToken {
            headers["Authorization"] = token
        }
        
        Alamofire.request(spRequest.url,
                          method: spRequest.method,
                          parameters: params,
                          encoding: APIConstants.encoding,
                          headers: headers)
            .validate()
            .responseJSON { [weak self] (response) in
                switch response.result {
                case .success(let json):
                    let dict = json as? NSDictionary
                    let success = dict?["success"] as? Bool ?? false
                    if success {
                        self?.updateSession(headers: response.response?.allHeaderFields, completion: completion)
                    } else {
                        let errorMessage = NSLocalizedString("Authentication error",
                                                             comment: "Authentication error")
                        let error = SPNetworkError.custom(errorMessage)
                        let rawReport = RawReportModel(
                            url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                            parameters: params,
                            errorData: response.data,
                            errorMessage: error.localizedDescription
                        )
                        SPDefaultFailureReporter().sendFailureReport(rawReport)
                        
                        self?.ssoAuthDelegate?.ssoFlowDidFail(with: error)
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
                    
                    self?.ssoAuthDelegate?.ssoFlowDidFail(with: SPNetworkError.default)
                    completion(false, SPNetworkError.default)
                }
            }
    }
    
    private func updateSession(headers: [AnyHashable: Any]?, completion: @escaping AuthCompletionHandler) {
        SPUserSessionHolder.updateSession(with: headers)
        let token = headers?.authorizationHeader
        SPDefaultInternalAuthProvider.login { [weak self] _, error in
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
