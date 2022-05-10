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
}

protocol AuthenticationPlaygroundViewModelingOutputs {
    var genericSSOOptions: Observable<[GenericSSOAuthentication]> { get }
    var JWTSSOOptions: Observable<[JWTSSOAuthentication]> { get }
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
    
    fileprivate let disposeBag = DisposeBag()

    init() {
        setupObservers()
    }
}

fileprivate extension AuthenticationPlaygroundViewModel {
    func setupObservers() {
        selectedGenericSSOOptionIndex
            .bind(to: _selectedGenericSSOOptionIndex)
            .disposed(by: disposeBag)
        
        selectedJWTSSOOptionIndex
            .bind(to: _selectedJWTSSOOptionIndex)
            .disposed(by: disposeBag)
        
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
            
    }
}

