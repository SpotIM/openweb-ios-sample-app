//
//  AuthenticationPlaygroundNewAPIViewModel.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 16/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire
import SpotImCore

#if NEW_API

protocol AuthenticationPlaygroundNewAPIViewModelingInputs {
    var selectedGenericSSOOptionIndex: PublishSubject<Int> { get }
    var selectedJWTSSOOptionIndex: PublishSubject<Int> { get }
    var logoutPressed: PublishSubject<Void> { get }
    var genericSSOAuthenticatePressed: PublishSubject<Void> { get }
    var JWTSSOAuthenticatePressed: PublishSubject<Void> { get }
    var initializeSDKToggled: PublishSubject<Bool> { get }
    var automaticallyDismissToggled: PublishSubject<Bool> { get }
    var dismissing: PublishSubject<Void> { get }
}

protocol AuthenticationPlaygroundNewAPIViewModelingOutputs {
    var title: String { get }
    var genericSSOOptions: Observable<[GenericSSOAuthentication]> { get }
    var JWTSSOOptions: Observable<[JWTSSOAuthentication]> { get }
    var genericSSOAuthenticationStatus: Observable<AuthenticationStatus> { get }
    var JWTSSOAuthenticationStatus: Observable<AuthenticationStatus> { get }
    var dismissVC: PublishSubject<Void> { get }
    var dismissed: Observable<Void> { get }
}

protocol AuthenticationPlaygroundNewAPIViewModeling {
    var inputs: AuthenticationPlaygroundNewAPIViewModelingInputs { get }
    var outputs: AuthenticationPlaygroundNewAPIViewModelingOutputs { get }
}

class AuthenticationPlaygroundNewAPIViewModel: AuthenticationPlaygroundNewAPIViewModeling,
                                                AuthenticationPlaygroundNewAPIViewModelingInputs,
                                                AuthenticationPlaygroundNewAPIViewModelingOutputs {
    var inputs: AuthenticationPlaygroundNewAPIViewModelingInputs { return self }
    var outputs: AuthenticationPlaygroundNewAPIViewModelingOutputs { return self }

    fileprivate struct Metrics {
        static let delayUntilDismissVC = 500 // milliseconds
    }

    fileprivate let _selectedGenericSSOOptionIndex = BehaviorSubject(value: 0)
    var selectedGenericSSOOptionIndex = PublishSubject<Int>()

    fileprivate let _selectedJWTSSOOptionIndex = BehaviorSubject(value: 0)
    var selectedJWTSSOOptionIndex = PublishSubject<Int>()

    fileprivate let shouldInitializeSDK = BehaviorSubject(value: false)
    var initializeSDKToggled = PublishSubject<Bool>()

    fileprivate let shouldAutomaticallyDismiss = BehaviorSubject(value: true)
    var automaticallyDismissToggled = PublishSubject<Bool>()

    var logoutPressed = PublishSubject<Void>()

    var dismissVC = PublishSubject<Void>()

    var genericSSOAuthenticatePressed = PublishSubject<Void>()
    var JWTSSOAuthenticatePressed = PublishSubject<Void>()

    lazy var title: String = {
        return NSLocalizedString("AuthenticationPlaygroundTitle", comment: "")
    }()

    fileprivate let _genericSSOOptions = BehaviorSubject(value: GenericSSOAuthentication.mockModels)
    var genericSSOOptions: Observable<[GenericSSOAuthentication]> {
        return _genericSSOOptions
            .asObservable()
    }

    fileprivate let _JWTSSOOptions = BehaviorSubject(value: JWTSSOAuthentication.mockModels)
    var JWTSSOOptions: Observable<[JWTSSOAuthentication]> {
        return _JWTSSOOptions
            .asObservable()
    }

    fileprivate let _genericSSOAuthenticationStatus = BehaviorSubject(value: AuthenticationStatus.initial)
    var genericSSOAuthenticationStatus: Observable<AuthenticationStatus> {
        return _genericSSOAuthenticationStatus
            .asObservable()
    }

    fileprivate let _JWTSSOAuthenticationStatus = BehaviorSubject(value: AuthenticationStatus.initial)
    var JWTSSOAuthenticationStatus: Observable<AuthenticationStatus> {
        return _JWTSSOAuthenticationStatus
            .asObservable()
    }

    var dismissing = PublishSubject<Void>()
    var dismissed: Observable<Void> {
        return dismissing
            .delay(.milliseconds(250), scheduler: MainScheduler.instance) // Allow some time for dismissing animation
    }

    fileprivate let disposeBag = DisposeBag()

    init() {
        setupObservers()
    }
}

fileprivate extension AuthenticationPlaygroundNewAPIViewModel {
    // swiftlint:disable function_body_length
    func setupObservers() {
        // Different generic SSO selected
        selectedGenericSSOOptionIndex
            .do(onNext: { [weak self] _ in
                self?._genericSSOAuthenticationStatus.onNext(.initial)
            })
            .bind(to: _selectedGenericSSOOptionIndex)
            .disposed(by: disposeBag)

        // Different JWT SSO selected
        selectedJWTSSOOptionIndex
            .do(onNext: { [weak self] _ in
                self?._JWTSSOAuthenticationStatus.onNext(.initial)
            })
            .bind(to: _selectedJWTSSOOptionIndex)
            .disposed(by: disposeBag)

        // Bind SDK initialization toggle
        initializeSDKToggled
            .do(onNext: { [weak self] _ in
                self?._genericSSOAuthenticationStatus.onNext(.initial)
                self?._JWTSSOAuthenticationStatus.onNext(.initial)
            })
            .bind(to: shouldInitializeSDK)
            .disposed(by: disposeBag)

        // Bind automatically dismiss toggle (after successful login)
        automaticallyDismissToggled
            .do(onNext: { [weak self] _ in
                self?._genericSSOAuthenticationStatus.onNext(.initial)
                self?._JWTSSOAuthenticationStatus.onNext(.initial)
            })
            .bind(to: shouldAutomaticallyDismiss)
            .disposed(by: disposeBag)

        // Logout
        logoutPressed
            .do(onNext: { [weak self] _ in
                self?._JWTSSOAuthenticationStatus.onNext(.initial)
                self?._genericSSOAuthenticationStatus.onNext(.initial)
            })
            .subscribe(onNext: {
                let authentication = OpenWeb.manager.authentication
                authentication.userStatus { loginStatus in
                    DLog("Before logout \(loginStatus))")
                    authentication.logout { result in
                        switch result {
                        case .success(_):
                            authentication.userStatus { loginStatus in
                                DLog("After logout \(loginStatus))")
                            }
                        case .failure(let error):
                            DLog("Logout error: \(error)")
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        // TODO change to new API
        // Generic SSO authentication started
        genericSSOAuthenticatePressed
            .flatMapLatest { [weak self] _ -> Observable<Int> in
                // 1. Retrieving selected generic SSO
                guard let self = self else { return .empty() }
                return self._selectedGenericSSOOptionIndex
                    .take(1)
            }
            .withLatestFrom(genericSSOOptions) { index, options -> GenericSSOAuthentication? in
                guard !options.isEmpty else {
                    DLog("There isn't any generic SSO preset")
                    return nil
                }
                return options[index]
            }
            .unwrap()
            .do(onNext: { [weak self] _ in
                self?._genericSSOAuthenticationStatus.onNext(.inProgress)
                self?._JWTSSOAuthenticationStatus.onNext(.initial)
            })
            .withLatestFrom(shouldInitializeSDK) { genericSSO, shouldInitializeSDK -> GenericSSOAuthentication in
                // 2. Initialize SDK with appropriate spotId if needed
                if (shouldInitializeSDK) {
                    var manager = OpenWeb.manager
                    manager.spotId = genericSSO.spotId
                }
                return genericSSO
            }
            .flatMapLatest { [weak self] genericSSO -> Observable<(String, GenericSSOAuthentication)> in
                // 3. Login user if needed
                guard let self = self else { return.just(("", genericSSO)) }
                return self.login(user: genericSSO.user)
                    .observe(on: MainScheduler.instance)
                    .catchAndReturn(nil) // Keep the main subscription in case of an error
                    .do(onNext: { [weak self] value in
                        if value == nil {
                            self?._genericSSOAuthenticationStatus.onNext(.failed)
                        }
                    })
                    .unwrap()
                    .map { ($0, genericSSO) }

            }
            .flatMapLatest { [weak self] token, genericSSO -> Observable<(String, String, GenericSSOAuthentication)> in
                // 4. Start SSO
                guard let self = self else { return Observable.empty() }
                return self.startSSO()
                    .observe(on: MainScheduler.instance)
                    .catchAndReturn(nil) // Keep the main subscription in case of an error
                    .do(onNext: { [weak self] value in
                        if value == nil {
                            self?._genericSSOAuthenticationStatus.onNext(.failed)
                        }
                    })
                    .unwrap()
                    .map { ($0, token, genericSSO) }
            }
            .flatMapLatest { [weak self] codeA, token, genericSSO -> Observable<String> in
            // 5. Retrieving Code B
            guard let self = self else { return Observable.empty() }
                return self.codeB(codeA: codeA, token: token, genericSSO: genericSSO)
                    .observe(on: MainScheduler.instance)
                    .catchAndReturn(nil) // Keep the main subscription in case of an error
                    .do(onNext: { [weak self] value in
                        if value == nil {
                            self?._genericSSOAuthenticationStatus.onNext(.failed)
                        }
                    })
                    .unwrap()
            }
            .flatMapLatest { [weak self] codeB -> Observable<Void> in
                // 6. Complete SSO
                guard let self = self else { return Observable.empty() }
                return self.completeSSO(codeB: codeB)
                    .observe(on: MainScheduler.instance)
                    .catchAndReturn(nil)
                    .do(onNext: { [weak self] value in
                        if value == nil {
                            self?._genericSSOAuthenticationStatus.onNext(.failed)
                        }
                    })
                    .unwrap()
                    .voidify()
            }
            .do(onNext: { [weak self] _ in
                self?._genericSSOAuthenticationStatus.onNext(.successful)
            })
            .withLatestFrom(shouldAutomaticallyDismiss)
            .filter { $0 == true }
            .delay(.milliseconds(Metrics.delayUntilDismissVC), scheduler: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                // 7. Rx back to the view layer to dismiss itself
                self?.outputs.dismissVC.onNext()
            })
            .subscribe()
            .disposed(by: disposeBag)

        // TODO change to new API
        // JWT SSO authentication started
        JWTSSOAuthenticatePressed
            .flatMapLatest { [weak self] _ -> Observable<Int> in
                // 1. Retrieving selected JWT SSO
                guard let self = self else { return .empty() }
                return self._selectedJWTSSOOptionIndex
                    .take(1)
            }
            .withLatestFrom(JWTSSOOptions) { index, options -> JWTSSOAuthentication? in
                guard !options.isEmpty else {
                    DLog("There isn't any JWT SSO preset")
                    return nil
                }
                return options[index]
            }
            .unwrap()
            .do(onNext: { [weak self] _ in
                self?._JWTSSOAuthenticationStatus.onNext(.inProgress)
                self?._genericSSOAuthenticationStatus.onNext(.initial)
            })
            .withLatestFrom(shouldInitializeSDK) { JWTSSO, shouldInitializeSDK -> JWTSSOAuthentication in
                // 2. Initialize SDK with appropriate spotId if needed
                if (shouldInitializeSDK) {
                    var manager = OpenWeb.manager
                    manager.spotId = JWTSSO.spotId
                }
                return JWTSSO
            }
            .flatMapLatest { [weak self] JWTSSO -> Observable<Void> in
                // 4. Perform SSO with JWT secret
                guard let self = self else { return Observable.empty() }
                return self.sso(jwtSecret: JWTSSO.JWTSecret)
                    .observe(on: MainScheduler.instance)
                    .catchAndReturn(nil) // Keep the main subscription in case of an error
                    .do(onNext: { [weak self] value in
                        if value == nil {
                            self?._JWTSSOAuthenticationStatus.onNext(.failed)
                        }
                    })
                    .unwrap()
            }
            .do(onNext: { [weak self] _ in
                self?._JWTSSOAuthenticationStatus.onNext(.successful)
            })
            .withLatestFrom(shouldAutomaticallyDismiss)
            .filter { $0 == true }
            .delay(.milliseconds(Metrics.delayUntilDismissVC), scheduler: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                // 5. Rx back to the view layer to dismiss itself
                self?.outputs.dismissVC.onNext()
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    // swiftlint:enable function_body_length

    func startSSO() -> Observable<String?> {
        return Observable.create { observer in
            let authentication = OpenWeb.manager.authentication
            authentication.sso(.start(completion: { result in
                switch result {
                case .success(let startSSOModel):
                    observer.onNext(startSSOModel.codeA)
                    observer.onCompleted()
                case .failure(let error):
                    DLog("Failed in 'startSSO' with error: \(error)")
                    observer.onError(error)
                }
            }))

            return Disposables.create()
        }
    }

    func completeSSO(codeB: String) -> Observable<String?> {
        return Observable.create { observer in
            let authentication = OpenWeb.manager.authentication
            authentication.sso(.complete(codeB: codeB, completion: { result in
                switch result {
                case .success(let completeSSOModel):
                    observer.onNext(completeSSOModel.userId)
                    observer.onCompleted()
                case .failure(let error):
                    DLog("Failed in 'completeSSO(codeB:)' with error: \(error)")
                    observer.onError(error)
                }
            }))

            return Disposables.create()
        }
    }

    // TODO add new API
    func sso(jwtSecret: String) -> Observable<Void?> {
        return .empty()
    }

    func login(user: UserAuthentication) -> Observable<String?> {
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

    func codeB(codeA: String, token: String, genericSSO: GenericSSOAuthentication) -> Observable<String?> {
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
}

#endif
