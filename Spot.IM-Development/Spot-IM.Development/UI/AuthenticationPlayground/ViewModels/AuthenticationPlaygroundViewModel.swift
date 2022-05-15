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
}

protocol AuthenticationPlaygroundViewModelingOutputs {
    var title: String { get }
    var genericSSOOptions: Observable<[GenericSSOAuthentication]> { get }
    var JWTSSOOptions: Observable<[JWTSSOAuthentication]> { get }
    var genericSSOAuthenticationStatus: Observable<AuthenticationStatus> { get }
    var JWTSSOAuthenticationStatus: Observable<AuthenticationStatus> { get }
}

protocol AuthenticationPlaygroundViewModeling {
    var inputs: AuthenticationPlaygroundViewModelingInputs { get }
    var outputs: AuthenticationPlaygroundViewModelingOutputs { get }
}

class AuthenticationPlaygroundViewModel: AuthenticationPlaygroundViewModeling, AuthenticationPlaygroundViewModelingInputs, AuthenticationPlaygroundViewModelingOutputs {
    var inputs: AuthenticationPlaygroundViewModelingInputs { return self }
    var outputs: AuthenticationPlaygroundViewModelingOutputs { return self }
    
    fileprivate let _selectedGenericSSOOptionIndex = BehaviorSubject(value: 0)
    var selectedGenericSSOOptionIndex = PublishSubject<Int>()
    
    fileprivate let _selectedJWTSSOOptionIndex = BehaviorSubject(value: 0)
    var selectedJWTSSOOptionIndex = PublishSubject<Int>()
    
    var logoutPressed = PublishSubject<Void>()
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
           
        // Logout
        logoutPressed
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
                        @unknown default:
                            DLog("SDK logout function returned unknown result")
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
            .withLatestFrom(genericSSOOptions) { index, options in
                return options[index]
            }
            .do(onNext: { [weak self] genricSSO in
                // 2. Initialize SDK with appropriate spotId
                self?._genericSSOAuthenticationStatus.onNext(.inProgress)
                SpotIm.initialize(spotId: genricSSO.spotId)
            })
            .flatMapLatest { [weak self] _ -> Observable<String> in
                // 3. Start SSO
                guard let self = self else { return Observable.empty() }
                return self.startSSO()
                    .catchAndReturn(nil) // Keep the main subscription in case of an error
                    .do(onNext: { [weak self] value in
                        if value == nil {
                            self?._genericSSOAuthenticationStatus.onNext(.failed)
                        }
                    })
                    .unwrap()
            }
            .flatMapLatest { [weak self] codeA -> Observable<String> in
                guard let self = self else { return Observable.empty() }
                return .just("codeB")
            }
            .flatMapLatest { [weak self] codeB -> Observable<Void> in
                // 4. Complete SSO
                guard let self = self else { return Observable.empty() }
                return self.completeSSO(codeB: codeB)
                    .catchAndReturn(nil)
                    .do(onNext: { [weak self] value in
                        if value == nil {
                            self?._genericSSOAuthenticationStatus.onNext(.failed)
                        }
                    })
                    .unwrap()
            }
            .subscribe(onNext: { [weak self] _ in
                self?._genericSSOAuthenticationStatus.onNext(.successful)
            })
            .disposed(by: disposeBag)
        
        // JWT SSO authentication started
        JWTSSOAuthenticatePressed
            .flatMapLatest { [weak self] _ -> Observable<Int> in
                // 1. Retrieving selected JWT SSO
                guard let self = self else { return .empty() }
                return self._selectedJWTSSOOptionIndex
                    .take(1)
            }
            .withLatestFrom(JWTSSOOptions) { index, options in
                return options[index]
            }
            .do(onNext: { [weak self] JWTSSO in
                // 2. Initialize SDK with appropriate spotId
                self?._JWTSSOAuthenticationStatus.onNext(.inProgress)
                SpotIm.initialize(spotId: JWTSSO.spotId)
            })
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
            .subscribe(onNext: { [weak self] _ in
                self?._JWTSSOAuthenticationStatus.onNext(.successful)
            })
            .disposed(by: disposeBag)
    }
    
    func startSSO() -> Observable<String?> {
        return Observable.create { observer in
            SpotIm.startSSO { response, error in
                if let error = error {
                    DLog("Failed in 'SpotIm.startSSO' with error: \(error.localizedDescription)")
                    observer.onError(error)
                } else if let response = response, let codeA = response.codeA {
                    observer.onNext(codeA)
                    observer.onCompleted()
                } else {
                    DLog("Failed in 'SpotIm.startSSO' without an error")
                    observer.onError(AuthenticationError.startSSOCodeAMissing)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func completeSSO(codeB: String) -> Observable<Void?> {
        return Observable.create { observer in
            SpotIm.completeSSO(with: codeB) { success, error in
                if let error = error {
                    DLog("Failed in 'SpotIm.completeSSO' with error: \(error.localizedDescription)")
                    observer.onError(error)
                } else if success == true {
                    observer.onNext(())
                    observer.onCompleted()
                } else {
                    DLog("Failed in 'SpotIm.completeSSO' without an error")
                    observer.onError(AuthenticationError.completeSSOFailed)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func sso(jwtSecret: String) -> Observable<Void?> {
        return Observable.create { observer in
            SpotIm.sso(withJwtSecret: jwtSecret) { response, error in
                if let error = error {
                    DLog("Failed in 'SpotIm.sso(jwtSecret:)' with error: \(error.localizedDescription)")
                    observer.onError(error)
                } else if let success = response?.success, success {
                    observer.onNext(())
                    observer.onCompleted()
                } else {
                    DLog("Failed in 'SpotIm.sso(jwtSecret:)' without an error")
                    observer.onError(AuthenticationError.JWTSSOFailed)
                }
            }
            
            return Disposables.create()
        }
    }
}

