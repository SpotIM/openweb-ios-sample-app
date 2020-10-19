//
//  SpotImAuthenticationProvider.swift
//  SpotImCore
//
//  Created by Rotem Itzhak on 30/12/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

public typealias AuthCompletionHandler = (_ success: Bool, _ error: Error?) -> Void
public typealias AuthStratCompleteionHandler = (_ response: SSOStartResponse?, _ error: Error?) -> Void

public protocol SSOAthenticationDelegate: AnyObject {
    func ssoFlowStarted()
    func ssoFlowDidSucceed()
    func ssoFlowDidFail(with error: Error?)
    func userLogout()
}

public struct SSOStartResponse: Codable {
    public var codeA: String?
    public var jwtToken: String?
    public var autoComplete: Bool = false
    public var success: Bool = false
}

internal class SpotImAuthenticationProvider {
        public weak var ssoAuthDelegate: SSOAthenticationDelegate?

        private let internalAuthProvider: SPInternalAuthProvider
        private let manager: ApiManager

        public init(manager: ApiManager, internalProvider: SPInternalAuthProvider) {
            self.manager = manager
            self.internalAuthProvider = internalProvider
        }

        public func startSSO(completion: @escaping AuthStratCompleteionHandler) {
            ssoAuthDelegate?.ssoFlowStarted()
            SPUserSessionHolder.resetUserSession()
            internalAuthProvider.login { (token, error) in
                if let error = error {
                    self.ssoAuthDelegate?.ssoFlowDidFail(with: error)
                    completion(nil, error)
                } else {
                    let newParams = SPCodeAParameters(token: token, secret: nil)
                    self.getCodeA(withGuest: newParams, completion: completion)
                }
            }
        }

        public func sso(withJwtSecret secret: String, completion: @escaping AuthStratCompleteionHandler) {
            ssoAuthDelegate?.ssoFlowStarted()
            SPUserSessionHolder.resetUserSession()
            internalAuthProvider.login { (token, error) in
                if let error = error {
                    self.ssoAuthDelegate?.ssoFlowDidFail(with: error)
                    completion(nil, error)
                } else {
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
            var requestParams: [String: Any] = [APIParamKeysContants.SPOT_ID: spotKey]

            if let secret = ssoParams?.secret {
                requestParams[APIParamKeysContants.SECRET] = secret
            }

            var headers = HTTPHeaders.basic(with: spotKey)
            headers[APIHeadersConstants.AUTHORIZATION] = ssoParams?.token ?? SPUserSessionHolder.session.token
            manager.execute(
                request: spRequest,
                parameters: requestParams,
                parser: JSONParser(),
                headers: headers
            ) { result, response in
                switch result {
                case .success(let json):
                    let codeA = json[APIParamKeysContants.CODE_A] as? String
                    let autocomplete = json[APIParamKeysContants.AUTO_COMPLETE] as? Bool ?? false
                    let result = SSOStartResponse(codeA: codeA,
                                                  jwtToken: ssoParams?.token,
                                                  autoComplete: autocomplete,
                                                  success: json[APIParamKeysContants.SUCCESS] as? Bool ?? false)
                    if result.autoComplete {
                        SPUserSessionHolder.updateSession(with: response.response)
                        firstly {
                            self.internalAuthProvider.user()
                        }.done { [weak self] _ in
                            self?.ssoAuthDelegate?.ssoFlowDidSucceed()
                            completion(result, nil)
                        }.catch { [weak self] error in
                            self?.ssoAuthDelegate?.ssoFlowDidFail(with: error)
                            completion(nil, error)
                        }

                    } else {
                        completion(result, nil)
                    }
                case .failure(let error):
                    let rawReport = RawReportModel(url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                                                   parameters: requestParams,
                                                   errorData: response.data,
                                                   errorMessage: error.localizedDescription)
                    SPDefaultFailureReporter.shared.sendFailureReport(rawReport)
                    self.ssoAuthDelegate?.ssoFlowDidFail(with: error)
                    completion(nil, SPNetworkError.default)
                }
            }
    }

    public func completeSSO(with codeB: String?,
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
        let params = [APIParamKeysContants.CODE_B: codeB]
        var headers = HTTPHeaders.basic(with: spotKey)
        if let token = SPUserSessionHolder.session.token {
            headers[APIHeadersConstants.AUTHORIZATION] = token
        }

        manager.execute(
            request: spRequest,
            parameters: params,
            parser: JSONParser(),
            headers: headers
        ) { (result, response) in
            switch result {
            case .success(let json):
                let success = json[APIParamKeysContants.SUCCESS] as? Bool ?? false
                if success {
                    let token = response.response?.allHeaderFields.authorizationHeader
                    SPUserSessionHolder.session.token = token ?? SPUserSessionHolder.session.token
                    firstly {
                        self.internalAuthProvider.user()
                    }.done { [weak self] user in
                        self?.ssoAuthDelegate?.ssoFlowDidSucceed()
                        completion(token != nil && !token!.isEmpty, nil)
                    }.catch { [weak self] error in
                        self?.ssoAuthDelegate?.ssoFlowDidFail(with: error)
                        completion(false, error)
                    }
                } else {
                    let errorMessage = LocalizationManager.localizedString(key: "Authentication error")
                    let error = SPNetworkError.custom(errorMessage)
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: params,
                        errorData: response.data,
                        errorMessage: error.localizedDescription
                    )
                    SPDefaultFailureReporter.shared.sendFailureReport(rawReport)

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
                SPDefaultFailureReporter.shared.sendFailureReport(rawReport)

                self.ssoAuthDelegate?.ssoFlowDidFail(with: SPNetworkError.default)
                completion(false, SPNetworkError.default)
            }
        }
    }

    public func getUser() -> Promise<SPUser> {
        return internalAuthProvider.user()
    }
    
    public func logout() -> Promise<Void> {
        return firstly {
            internalAuthProvider.logout()
        }.then {
            self.internalAuthProvider.user()
        }.map { _ in
            self.ssoAuthDelegate?.userLogout()
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
