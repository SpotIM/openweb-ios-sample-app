//
//  SilentSSOAuthenticationNewAPI.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 21/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

#if NEW_API

protocol SilentSSOAuthenticationNewAPIProtocol {
    func silentSSO(for genericSSO: GenericSSOAuthentication, ignoreLoginStatus: Bool) -> Observable<String>
}

class SilentSSOAuthenticationNewAPI: SilentSSOAuthenticationNewAPIProtocol {
    func silentSSO(for genericSSO: GenericSSOAuthentication, ignoreLoginStatus: Bool) -> Observable<String> {
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
                return self.codeB(codeA: codeA, token: token, genericSSO: genericSSO)
            }
            .flatMapLatest { [weak self] codeB -> Observable<String> in
                // Complete SSO
                guard let self = self else { return .empty() }
                return self.completeSSO(codeB: codeB)
            }
    }
}

fileprivate extension SilentSSOAuthenticationNewAPI {
    func startSSO() -> Observable<String> {
        return Observable.create { observer in
            let authentication = OpenWeb.manager.authentication
            authentication.sso(.start(completion: { result in
                switch result {
                case .success(let ssoStartModel):
                    observer.onNext(ssoStartModel.codeA)
                    observer.onCompleted()
                case .failure(let error):
                    DLog("Failed in 'startSSO' with error: \(error)")
                    observer.onError(error)
                }
            }))

            return Disposables.create()
        }
    }

    func completeSSO(codeB: String) -> Observable<String> {
        return Observable.create { observer in
            let authentication = OpenWeb.manager.authentication
            authentication.sso(.complete(codeB: codeB, completion: { result in
                switch result {
                case .success(let ssoCompleteModel):
                    observer.onNext(ssoCompleteModel.userId)
                    observer.onCompleted()
                case .failure(let error):
                    DLog("Failed in 'completeSSO(codeB:)' with error: \(error)")
                    observer.onError(error)
                }
            }))

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

    func codeB(codeA: String, token: String, genericSSO: GenericSSOAuthentication) -> Observable<String> {
        return Observable.create { observer in
            DemoUserAuthentication.getCodeB(with: codeA,
                                            accessToken: token,
                                            username: genericSSO.user.username,
                                            accessTokenNetwork: genericSSO.ssoToken) { codeB, error in
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

    func userLoginStatus() -> Observable<OWUserAuthenticationStatus> {
        return Observable.create { observer in
            let authentication = OpenWeb.manager.authentication
            authentication.userStatus { loginStatus in
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

#endif
