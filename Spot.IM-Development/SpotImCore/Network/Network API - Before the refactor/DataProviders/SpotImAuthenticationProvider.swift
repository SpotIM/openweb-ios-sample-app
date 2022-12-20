//
//  SpotImAuthenticationProvider.swift
//  SpotImCore
//
//  Created by Rotem Itzhak on 30/12/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

public typealias AuthCompletionHandler = (Swift.Result<String, Error>) -> Void
public typealias AuthStratCompleteionHandler = (Swift.Result<SSOStartResponse, Error>) -> Void

public struct SSOStartResponse: Codable {
    public var codeA: String?
    public var jwtToken: String?
    public var autoComplete: Bool = false
    public var success: Bool = false
}

protocol SSOAthenticationDelegate: AnyObject {
    func ssoFlowStarted()
    func ssoFlowDidSucceed()
    func ssoFlowDidFail(with error: Error?)
    func userLogout()
    func renewSSO(userId: String)
}

struct SSOStartResponseInternal: Codable {
    var codeA: String?
    var autoComplete: Bool = false
    var success: Bool = false
    var user: SPUser?
}

struct SSOCompleteResponseInternal: Codable {
    var success: Bool = false
    var user: SPUser?
}


class SpotImAuthenticationProvider {
    weak var ssoAuthDelegate: SSOAthenticationDelegate? {
        didSet {
            // An ugly solution for a bad architecture scenario..
            // Since the coordinator might create only after `renewSSOPublish` emit an event,
            // We need to check if there was a renew event once the coordinator set itself as the delegate to this `SpotIm AuthenticationProvider` class.
            if let delegate = ssoAuthDelegate {
                _ = renewSSOBehavior
                    .take(1) // No need to dispose since we take only the first one
                    .unwrap()
                    .subscribe(onNext: { [weak delegate] userId in
                        delegate?.renewSSO(userId: userId)
                    })
                // Prepare of a new coordinator creates (cannot happen in the current architecture but still).
                renewSSOBehavior.onNext(nil)
            }
        }
    }
    
    // Should be in a protocol like with MVVM, but I will leave it for a bigger refactor
    let renewSSOPublish = PublishSubject<String>()
    fileprivate let renewSSOBehavior = BehaviorSubject<String?>(value: nil)
    fileprivate let disposeBag = DisposeBag()
    
    private let internalAuthProvider: SPInternalAuthProvider
    private let manager: OWApiManager
    
    init(manager: OWApiManager, internalProvider: SPInternalAuthProvider) {
        self.manager = manager
        self.internalAuthProvider = internalProvider
        
        setupObservers()
    }
    
    func startSSO(completion: @escaping AuthStratCompleteionHandler) {
        _ = Observable.just(()) // Begin RX flow
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                if SPUserSessionHolder.isRegister() { // In such case logout first
                    return self.logout()
                        .catchAndReturn(()) // Just continue in case of an error
                } else {
                    return .just(())
                }
            }
            .take(1) // No need to disposed since we take 1
            .do(onNext: { [weak self] _ in
                self?.ssoAuthDelegate?.ssoFlowStarted()
                SPUserSessionHolder.resetUserSession()
            })
                .flatMapLatest { [weak self] _ -> Observable<String> in
                    guard let self = self else { return .empty() }
                    return self.internalAuthProvider.login()
                }
                .take(1) // No need to disposed since we take 1
                .subscribe(onNext: { [weak self] token in
                    let newParams = SPCodeAParameters(token: token, secret: nil)
                    self?.getCodeA(withGuest: newParams, completion: completion)
                }, onError: { [weak self] error in
                    self?.ssoAuthDelegate?.ssoFlowDidFail(with: error)
                    completion(.failure(error))
                })
    }
    
    func sso(withJwtSecret secret: String, completion: @escaping AuthStratCompleteionHandler) {
        ssoAuthDelegate?.ssoFlowStarted()
        SPUserSessionHolder.resetUserSession()
        _ = internalAuthProvider.login()
            .take(1) // No need to disposed since we take 1
            .subscribe(onNext: { [weak self] token in
                let newParams = SPCodeAParameters(token: token, secret: secret)
                self?.getCodeA(withGuest: newParams, completion: completion)
            }, onError: { [weak self] error in
                self?.ssoAuthDelegate?.ssoFlowDidFail(with: error)
                completion(.failure(error))
            })
    }
    
    private func getCodeA(withGuest ssoParams: SPCodeAParameters?,
                          completion: @escaping AuthStratCompleteionHandler) {
        guard let spotKey = SPClientSettings.main.spotKey else {
            let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
            completion(.failure(SPNetworkError.custom(message)))
            return
        }
        let spRequest = SPInternalAuthRequests.ssoStart
        var requestParams: [String: Any] = [APIParamKeysContants.SPOT_ID: spotKey]
        
        if let secret = ssoParams?.secret {
            requestParams[APIParamKeysContants.SECRET] = secret
        }
        
        var headers = HTTPHeaders.basic(with: spotKey)
        headers[APIHeadersConstants.authorization] = ssoParams?.token ?? SPUserSessionHolder.session.token
        manager.execute(
            request: spRequest,
            parameters: requestParams,
            parser: OWDecodableParser<SSOStartResponseInternal>(),
            headers: headers
        ) { result, response in
            switch result {
            case .success(let ssoResponse):
                let result = SSOStartResponse(codeA: ssoResponse.codeA,
                                              jwtToken: ssoParams?.token,
                                              autoComplete: ssoResponse.autoComplete,
                                              success: ssoResponse.success)
                if ssoResponse.autoComplete {
                    SPUserSessionHolder.updateSession(with: response.response)
                    
                    if let user = ssoResponse.user {
                        SPUserSessionHolder.updateSessionUser(user: user)
                    }
                    
                    self.ssoAuthDelegate?.ssoFlowDidSucceed()
                    completion(.success(result))
                } else {
                    completion(.success(result))
                }
            case .failure(let error):
                let rawReport = RawReportModel(url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                                               parameters: requestParams,
                                               errorData: response.data,
                                               errorMessage: error.localizedDescription)
                SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
                self.ssoAuthDelegate?.ssoFlowDidFail(with: error)
                completion(.failure(SPNetworkError.default))
            }
        }
    }
    
    func completeSSO(with codeB: String?,
                     completion: @escaping AuthCompletionHandler) {
        guard SPUserSessionHolder.isRegister() == false else {
            let message = LocalizationManager.localizedString(key: "User is already logged in.")
            completion(.failure(SpotImError.internalError(message)))
            return
        }
        guard let spotKey = SPClientSettings.main.spotKey else {
            let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
            completion(.failure(SPNetworkError.custom(message)))
            return
        }
        guard let codeB = codeB else {
            let message = LocalizationManager.localizedString(key: "Please provide Code B")
            completion(.failure(SPNetworkError.custom(message)))
            return
        }
        let spRequest = SPInternalAuthRequests.ssoComplete
        let params = [APIParamKeysContants.CODE_B: codeB]
        var headers = HTTPHeaders.basic(with: spotKey)
        if let token = SPUserSessionHolder.session.token {
            headers[APIHeadersConstants.authorization] = token
        }
        
        self.manager.execute(
            request: spRequest,
            parameters: params,
            parser: OWDecodableParser<SSOCompleteResponseInternal>(),
            headers: headers
        ) { (result, response) in
            switch result {
            case .success(let ssoResponse):
                if ssoResponse.success {
                    let token = response.response?.allHeaderFields.authorizationHeader
                    SPUserSessionHolder.session.token = token ?? SPUserSessionHolder.session.token
                    guard let user = ssoResponse.user, let userId = user.id else {
                        let message = LocalizationManager.localizedString(key: "Failed to get user in SSO complete")
                        let error = SpotImError.internalError(message)
                        self.ssoAuthDelegate?.ssoFlowDidFail(with: error)
                        completion(.failure(error))
                        return
                    }
                    
                    SPUserSessionHolder.updateSessionUser(user: user)
                    self.ssoAuthDelegate?.ssoFlowDidSucceed()
                    completion(.success(userId))
                } else {
                    let errorMessage = LocalizationManager.localizedString(key: "Authentication error")
                    let error = SPNetworkError.custom(errorMessage)
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: params,
                        errorData: response.data,
                        errorMessage: error.localizedDescription
                    )
                    SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
                    
                    self.ssoAuthDelegate?.ssoFlowDidFail(with: error)
                    completion(.failure(error))
                }
            case .failure(let error):
                let rawReport = RawReportModel(
                    url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                    parameters: nil,
                    errorData: response.data,
                    errorMessage: error.localizedDescription
                )
                SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
                
                self.ssoAuthDelegate?.ssoFlowDidFail(with: SPNetworkError.default)
                completion(.failure(SPNetworkError.default))
            }
        }
        
    }
    
    func getUser() -> Observable<SPUser> {
        return internalAuthProvider.user()
    }
    
    func logout() -> Observable<Void> {
        return internalAuthProvider.logout()
            .flatMapLatest { [weak self] _ -> Observable<SPUser> in
                guard let self = self else { return .empty() }
                return self.internalAuthProvider.user()
            }
            .voidify()
            .do(onNext: { [weak self] _ in
                self?.ssoAuthDelegate?.userLogout()
            })
    }
}

extension SpotImAuthenticationProvider {
    func setupObservers() {
        renewSSOPublish
            .subscribe(onNext: { [weak self] userId in
                guard let self = self else { return }
                self.ssoAuthDelegate?.renewSSO(userId: userId)
            })
            .disposed(by: disposeBag)
        
        renewSSOPublish
            .bind(to: renewSSOBehavior)
            .disposed(by: disposeBag)
    }
}

private struct SPCodeAParameters {
    init(token: String? = nil, secret: String? = nil) {
        self.token = token
        self.secret = secret
    }
    var token: String?
    var secret: String?
}
