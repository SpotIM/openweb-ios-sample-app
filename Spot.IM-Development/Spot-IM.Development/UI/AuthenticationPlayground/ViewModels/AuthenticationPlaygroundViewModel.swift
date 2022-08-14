//
//  AuthenticationPlaygroundViewModel.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 10/05/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire
import SpotImCore

protocol AuthenticationPlaygroundViewModelingInputs {
    var selectedGenericSSOOptionIndex: PublishSubject<Int> { get }
    var selectedJWTSSOOptionIndex: PublishSubject<Int> { get }
    var logoutPressed: PublishSubject<Void> { get }
    var genericSSOAuthenticatePressed: PublishSubject<Void> { get }
    var JWTSSOAuthenticatePressed: PublishSubject<Void> { get }
    var initializeSDKToggled: PublishSubject<Bool> { get }
    var automaticallyDismissToggled: PublishSubject<Bool> { get }
}

protocol AuthenticationPlaygroundViewModelingOutputs {
    var title: String { get }
    var genericSSOOptions: Observable<[GenericSSOAuthentication]> { get }
    var JWTSSOOptions: Observable<[JWTSSOAuthentication]> { get }
    var genericSSOAuthenticationStatus: Observable<AuthenticationStatus> { get }
    var JWTSSOAuthenticationStatus: Observable<AuthenticationStatus> { get }
    var dismissVC: PublishSubject<Void> { get }
}

protocol AuthenticationPlaygroundViewModeling {
    var inputs: AuthenticationPlaygroundViewModelingInputs { get }
    var outputs: AuthenticationPlaygroundViewModelingOutputs { get }
}

class AuthenticationPlaygroundViewModel: AuthenticationPlaygroundViewModeling, AuthenticationPlaygroundViewModelingInputs, AuthenticationPlaygroundViewModelingOutputs {
    var inputs: AuthenticationPlaygroundViewModelingInputs { return self }
    var outputs: AuthenticationPlaygroundViewModelingOutputs { return self }
    
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
    
    fileprivate let disposeBag = DisposeBag()
    
    init() {
        setupObservers()
    }
}

fileprivate extension AuthenticationPlaygroundViewModel {
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
            .do(onNext: { [weak self] JWTSSO in
                self?._JWTSSOAuthenticationStatus.onNext(.initial)
                self?._genericSSOAuthenticationStatus.onNext(.initial)
            })
            .subscribe(onNext: {
                SpotIm.getUserLoginStatus { loginStatus in
                    DLog("Before logout \(loginStatus))")
                    SpotIm.logout { result in
                        switch result {
                        case .success(_):
                            SpotIm.getUserLoginStatus { loginStatus in
                                DLog("After logout \(loginStatus))")
                            }
                        case .failure(let error):
                            DLog("Logout error: \(error)")
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
           
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
            .do(onNext: { [weak self] genricSSO in
                self?._genericSSOAuthenticationStatus.onNext(.inProgress)
                self?._JWTSSOAuthenticationStatus.onNext(.initial)
            })
            .withLatestFrom(shouldInitializeSDK) { genricSSO, shouldInitializeSDK -> GenericSSOAuthentication in
                // 2. Initialize SDK with appropriate spotId if needed
                if (shouldInitializeSDK) {
                    SpotIm.reinit = true
                    SpotIm.initialize(spotId: genricSSO.spotId)
                }
                return genricSSO
            }
            .flatMapLatest { [weak self] genricSSO -> Observable<(String, GenericSSOAuthentication)> in
                // 3. Login user if needed
                guard let self = self else { return.just(("", genricSSO)) }
                return self.login(user: genricSSO.user)
                    .catchAndReturn(nil) // Keep the main subscription in case of an error
                    .do(onNext: { [weak self] value in
                        if value == nil {
                            self?._genericSSOAuthenticationStatus.onNext(.failed)
                        }
                    })
                    .unwrap()
                    .map { ($0, genricSSO) }
                    
            }
            .flatMapLatest { [weak self] token, genricSSO -> Observable<(String, String, GenericSSOAuthentication)> in
                // 4. Start SSO
                guard let self = self else { return Observable.empty() }
                return self.startSSO()
                    .catchAndReturn(nil) // Keep the main subscription in case of an error
                    .do(onNext: { [weak self] value in
                        if value == nil {
                            self?._genericSSOAuthenticationStatus.onNext(.failed)
                        }
                    })
                    .unwrap()
                    .map { ($0, token, genricSSO) }
            }
            .flatMapLatest { [weak self] codeA, token, genricSSO -> Observable<String> in
            // 5. Retrieving Code B
            guard let self = self else { return Observable.empty() }
                return self.codeB(codeA: codeA, token: token, user: genricSSO.user)
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
            .do(onNext: { [weak self] JWTSSO in
                self?._JWTSSOAuthenticationStatus.onNext(.inProgress)
                self?._genericSSOAuthenticationStatus.onNext(.initial)
            })
            .withLatestFrom(shouldInitializeSDK) { JWTSSO, shouldInitializeSDK -> JWTSSOAuthentication in
                // 2. Initialize SDK with appropriate spotId if needed
                if (shouldInitializeSDK) {
                    SpotIm.reinit = true
                    SpotIm.initialize(spotId: JWTSSO.spotId)
                }
                return JWTSSO
            }
            .flatMapLatest { [weak self] JWTSSO -> Observable<Void> in
                // 4. Perform SSO with JWT secret
                guard let self = self else { return Observable.empty() }
                return self.sso(jwtSecret: JWTSSO.JWTSecret)
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
    
    func startSSO() -> Observable<String?> {
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
    
    func completeSSO(codeB: String) -> Observable<String?> {
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
    
    func sso(jwtSecret: String) -> Observable<Void?> {
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
    
    func codeB(codeA: String, token: String, user: UserAuthentication) -> Observable<String?> {
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
}

