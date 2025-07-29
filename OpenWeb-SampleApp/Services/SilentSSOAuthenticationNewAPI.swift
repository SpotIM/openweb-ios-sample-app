//
//  SilentSSOAuthenticationNewAPI.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 21/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import Combine
import OpenWebSDK

protocol SilentSSOAuthenticationNewAPIProtocol {
    func silentSSO(for genericSSO: GenericSSOAuthentication, ignoreLoginStatus: Bool) -> AnyPublisher<String, Error>
}

class SilentSSOAuthenticationNewAPI: SilentSSOAuthenticationNewAPIProtocol {
    func silentSSO(for genericSSO: GenericSSOAuthentication, ignoreLoginStatus: Bool) -> AnyPublisher<String, Error> {
        return AnyPublisher<Void, Error>.just(()) // Begin RX
            .flatMapLatest { [unowned self] _ -> AnyPublisher<Void, Error> in
                // Check user login status if needed
                if ignoreLoginStatus {
                    return .just(())
                } else {
                    return self.userLoginStatus()
                        .map { loginStatus in
                            if case .ssoLoggedIn = loginStatus {
                                return false
                            } else {
                                return true
                            }
                        }
                        .filter { $0 } // continue only if user not logged in
                        .voidify()
                }
            }
            .flatMapLatest { [unowned self] _ -> AnyPublisher<String, Error> in
                // Login
                return self.login(user: genericSSO.user)
            }
            .flatMapLatest { [unowned self] token -> AnyPublisher<(String, String), Error> in
                // Start SSO
                return self.startSSO()
                    .map { ($0, token) }
                    .eraseToAnyPublisher()
            }
            .flatMapLatest { [unowned self] codeA, token -> AnyPublisher<String, Error> in
                // Get codeB
                return self.codeB(codeA: codeA, token: token, genericSSO: genericSSO)
            }
            .flatMapLatest { [unowned self] codeB -> AnyPublisher<String, Error> in
                // Complete SSO
                return self.completeSSO(codeB: codeB)
            }
            .eraseToAnyPublisher()
    }
}

private extension SilentSSOAuthenticationNewAPI {
    func startSSO() -> AnyPublisher<String, Error> {
        return AnyPublisher.create { observer in
            let authentication = OpenWeb.manager.authentication
            authentication.sso(.start(completion: { result in
                switch result {
                case .success(let ssoStartModel):
                    observer.send(ssoStartModel.codeA)
                    observer.send(completion: .finished)
                case .failure(let error):
                    DLog("Failed in 'startSSO' with error: \(error)")
                    observer.send(completion: .failure(error))
                }
            }))

            return AnyCancellable {}
        }
    }

    func completeSSO(codeB: String) -> AnyPublisher<String, Error> {
        return AnyPublisher.create { observer in
            let authentication = OpenWeb.manager.authentication
            authentication.sso(.complete(codeB: codeB, completion: { result in
                switch result {
                case .success(let ssoCompleteModel):
                    observer.send(ssoCompleteModel.userId)
                    observer.send(completion: .finished)
                case .failure(let error):
                    DLog("Failed in 'completeSSO(codeB:)' with error: \(error)")
                    observer.send(completion: .failure(error))
                }
            }))

            return AnyCancellable {}
        }
    }

    func login(user: UserAuthentication) -> AnyPublisher<String, Error> {
        return AnyPublisher.create { observer in
            DemoUserAuthentication.logIn(with: user.username, password: user.password) { token, error in
                guard let token else {
                    let loginError = error != nil ? error! : AuthenticationError.userLoginFailed
                    DLog("Failed in 'login(user:)' with error: \(loginError)")
                    observer.send(completion: .failure(loginError))
                    return
                }
                observer.send(token)
                observer.send(completion: .finished)
            }
            return AnyCancellable {}
        }
    }

    func codeB(codeA: String, token: String, genericSSO: GenericSSOAuthentication) -> AnyPublisher<String, Error> {
        return AnyPublisher.create { observer in
            DemoUserAuthentication.getCodeB(with: codeA,
                                            accessToken: token,
                                            username: genericSSO.user.username,
                                            accessTokenNetwork: genericSSO.ssoToken) { codeB, error in
                guard let codeB else {
                    let codeBError = error != nil ? error! : AuthenticationError.codeBFailed
                    DLog("Failed in 'codeB(codeA:token:user:)' with error: \(codeBError)")
                    observer.send(completion: .failure(codeBError))
                    return
                }
                observer.send(codeB)
                observer.send(completion: .finished)
            }

            return AnyCancellable {}
        }
    }

    func userLoginStatus() -> AnyPublisher<OWUserAuthenticationStatus, Error> {
        return AnyPublisher.create { observer in
            let authentication = OpenWeb.manager.authentication
            authentication.userStatus { loginStatus in
                switch loginStatus {
                case .success(let status):
                    observer.send(status)
                    observer.send(completion: .finished)
                case .failure(let error):
                    observer.send(completion: .failure(error))
                }
            }

            return AnyCancellable {}
        }
    }
}
