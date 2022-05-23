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
        return Observable.empty()
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
