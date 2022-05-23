//
//  SilentSSOAuthentication.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 23/05/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

protocol SilentSSOAuthenticationProtocol {
    func silentGenericSSO(for genericSSO: GenericSSOAuthentication, ignoreLoginStatus: Bool) -> Observable<String>
}

class SilentSSOAuthentication: SilentSSOAuthenticationProtocol {
    
    func silentGenericSSO(for genericSSO: GenericSSOAuthentication, ignoreLoginStatus: Bool) -> Observable<String> {
        return Observable.just(()) // Begin RX
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                // Check user login status if needed
                guard let self = self else { return .empty() }
                if ignoreLoginStatus {
                    return .just(())
                } else {
                    return self.userLoginStatus()
                        .map { loginStatus in
                            if case .ssoLoggedIn(_) = loginStatus {
                                return false
                            } else {
                                return true
                            }
                        }
                        .filter { $0 } // continue only if user not logged in
                        .voidify()
                }
            }
            .flatMapLatest { [weak self] _ -> Observable<String> in
                // Login
                guard let self = self else { return .empty() }
                return self.login(user: genericSSO.user)
            }
            .flatMapLatest { [weak self] token -> Observable<(String, String)> in
                // Start SSO
                guard let self = self else { return .empty() }
                return self.startSSO()
                    .map { ($0, token) }
            }
            .flatMapLatest { [weak self] codeA, token -> Observable<String> in
                // Get codeB
                guard let self = self else { return .empty() }
                return self.codeB(codeA: codeA, token: token, user: genericSSO.user)
            }
            .flatMapLatest { [weak self] codeB -> Observable<String> in
                // Complete SSO
                guard let self = self else { return .empty() }
                return self.completeSSO(codeB: codeB)
            }
    }
}

fileprivate extension SilentSSOAuthentication {
    func startSSO() -> Observable<String> {
        return Observable.create { observer in
            SpotIm.startSSO { result in
                switch result {
                case .success(let ssoResponse):
                    guard let codeA = ssoResponse.codeA else {
                        DLog("Failed in 'startSSO' because code a missing")
                        observer.onError(AuthenticationError.startSSOCodeAMissing)
                        return
                    }
                    observer.onNext(codeA)
                    observer.onCompleted()
                case .failure(let error):
                    DLog("Failed in 'startSSO' with error: \(error)")
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func completeSSO(codeB: String) -> Observable<String> {
        return Observable.create { observer in
            SpotIm.completeSSO(with: codeB) { result in
                switch result {
                case .success(let userId):
                    observer.onNext(userId)
                    observer.onCompleted()
                case .failure(let error):
                    DLog("Failed in 'completeSSO(codeB:)' with error: \(error)")
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func sso(jwtSecret: String) -> Observable<Void> {
        return Observable.create { observer in
            SpotIm.sso(withJwtSecret: jwtSecret) { result in
                switch result {
                case .success(let ssoResponse):
                    guard ssoResponse.success else {
                        DLog("Failed in 'sso(jwtSecret:)' without an error")
                        observer.onError(AuthenticationError.JWTSSOFailed)
                        return
                    }
                    
                    observer.onNext(())
                    observer.onCompleted()
                case .failure(let error):
                    DLog("Failed in 'sso(jwtSecret:)' with error: \(error)")
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func login(user: UserAuthentication) -> Observable<String> {
        return Observable.create { observer in
            DemoUserAuthentication.logIn(with: user.username, password: user.password) { token, error in
                guard let token = token else {
                    let loginError = error != nil ? error! : AuthenticationError.userLoginFailed
                    DLog("Failed in 'login(user:)' with error: \(loginError)")
                    observer.onError(loginError)
                    return
                }
                observer.onNext(token)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func codeB(codeA: String, token: String, user: UserAuthentication) -> Observable<String> {
        return Observable.create { observer in
            DemoUserAuthentication.getCodeB(with: codeA,
                                                accessToken: token,
                                                username: user.username,
                                                accessTokenNetwork: user.userToken) { codeB, error in
                guard let codeB = codeB else {
                    let codeBError = error != nil ? error! : AuthenticationError.codeBFailed
                    DLog("Failed in 'codeB(codeA:token:user:)' with error: \(codeBError)")
                    observer.onError(codeBError)
                    return
                }
                observer.onNext(codeB)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func userLoginStatus() -> Observable<SpotImLoginStatus> {
        return Observable.create { observer in
            SpotIm.getUserLoginStatus { loginStatus in
                switch loginStatus {
                case .success(let status):
                    observer.onNext(status)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
}
