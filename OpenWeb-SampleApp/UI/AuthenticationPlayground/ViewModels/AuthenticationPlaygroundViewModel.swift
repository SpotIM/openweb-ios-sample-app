//
//  AuthenticationPlaygroundNewAPIViewModel.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 16/01/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire
import OpenWebSDK

protocol AuthenticationPlaygroundViewModelingInputs {
    var selectedGenericSSOOptionIndex: PublishSubject<Int> { get }
    var selectedThirdPartySSOOptionIndex: PublishSubject<Int> { get }
    var logoutPressed: PublishSubject<Void> { get }
    var genericSSOAuthenticatePressed: PublishSubject<Void> { get }
    var thirdPartySSOAuthenticatePressed: PublishSubject<Void> { get }
    var initializeSDKToggled: PublishSubject<Bool> { get }
    var automaticallyDismissToggled: PublishSubject<Bool> { get }
    var dismissing: PublishSubject<Void> { get }
    var closeClick: PublishSubject<Void> { get }
    var customSSOToken: BehaviorSubject<String> { get }
    var customUsername: BehaviorSubject<String> { get }
    var customPassword: BehaviorSubject<String> { get }
}

protocol AuthenticationPlaygroundViewModelingOutputs {
    var title: String { get }
    var genericSSOOptions: Observable<[GenericSSOAuthentication]> { get }
    var thirdPartySSOOptions: Observable<[ThirdPartySSOAuthentication]> { get }
    var genericSSOAuthenticationStatus: Observable<AuthenticationStatus> { get }
    var thirdPartySSOAuthenticationStatus: Observable<AuthenticationStatus> { get }
    var logoutAuthenticationStatus: Observable<AuthenticationStatus> { get }
    var dismissVC: PublishSubject<Void> { get }
    var dismissed: Observable<Void> { get }
    var customSSOTokenChanged: Observable<String> { get }
    var customUsernameChanged: Observable<String> { get }
    var customPasswordChanged: Observable<String> { get }
}

protocol AuthenticationPlaygroundViewModeling {
    var inputs: AuthenticationPlaygroundViewModelingInputs { get }
    var outputs: AuthenticationPlaygroundViewModelingOutputs { get }
}

class AuthenticationPlaygroundViewModel: AuthenticationPlaygroundViewModeling,
                                                AuthenticationPlaygroundViewModelingInputs,
                                                AuthenticationPlaygroundViewModelingOutputs {
    var inputs: AuthenticationPlaygroundViewModelingInputs { return self }
    var outputs: AuthenticationPlaygroundViewModelingOutputs { return self }

    private struct Metrics {
        static let delayUntilDismissVC = 500 // milliseconds
        static let delayInsertSSOPresetData = 100 // milliseconds
    }

    private let _selectedGenericSSOOptionIndex = BehaviorSubject(value: 0)
    var selectedGenericSSOOptionIndex = PublishSubject<Int>()

    private let _selectedThirdPartySSOOptionIndex = BehaviorSubject(value: 0)
    var selectedThirdPartySSOOptionIndex = PublishSubject<Int>()

    private let shouldInitializeSDK = BehaviorSubject(value: false)
    var initializeSDKToggled = PublishSubject<Bool>()

    private let shouldAutomaticallyDismiss = BehaviorSubject(value: true)
    var automaticallyDismissToggled = PublishSubject<Bool>()

    var logoutPressed = PublishSubject<Void>()

    var dismissVC = PublishSubject<Void>()

    var genericSSOAuthenticatePressed = PublishSubject<Void>()
    var thirdPartySSOAuthenticatePressed = PublishSubject<Void>()

    var customSSOToken = BehaviorSubject<String>(value: "")
    var customUsername = BehaviorSubject<String>(value: "")
    var customPassword = BehaviorSubject<String>(value: "")

    lazy var customSSOTokenChanged: Observable<String> = {
        return customSSOToken
            .asObservable()
    }()

    lazy var customUsernameChanged: Observable<String> = {
        return customUsername
            .asObservable()
    }()

    lazy var customPasswordChanged: Observable<String> = {
        return customPassword
            .asObservable()
    }()

    lazy var title: String = {
        return NSLocalizedString("AuthenticationPlaygroundTitle", comment: "")
    }()

    lazy var genericSSOAuthenticationModels: [GenericSSOAuthentication] = {
        var models = GenericSSOAuthentication.mockModels

        if let spotId = spotIdToFilterBy {
            models = models.filter { $0.spotId == spotId }
        }

        return models
    }()

    private lazy var _genericSSOOptions = BehaviorSubject(value: genericSSOAuthenticationModels)
    var genericSSOOptions: Observable<[GenericSSOAuthentication]> {
        return _genericSSOOptions
            .asObservable()
    }

    lazy var thirdPartySSOAuthenticationModels: [ThirdPartySSOAuthentication] = {
        var models = ThirdPartySSOAuthentication.mockModels

        if let spotId = spotIdToFilterBy {
            models = models.filter { $0.spotId == spotId }
        }

        return models
    }()

    private lazy var _thirdPartySSOOptions = BehaviorSubject(value: thirdPartySSOAuthenticationModels)
    var thirdPartySSOOptions: Observable<[ThirdPartySSOAuthentication]> {
        return _thirdPartySSOOptions
            .asObservable()
    }

    private let _genericSSOAuthenticationStatus = BehaviorSubject(value: AuthenticationStatus.initial)
    var genericSSOAuthenticationStatus: Observable<AuthenticationStatus> {
        return _genericSSOAuthenticationStatus
            .asObservable()
    }

    private let _thirdPartySSOAuthenticationStatus = BehaviorSubject(value: AuthenticationStatus.initial)
    var thirdPartySSOAuthenticationStatus: Observable<AuthenticationStatus> {
        return _thirdPartySSOAuthenticationStatus
            .asObservable()
    }

    private let _logoutAuthenticationStatus = BehaviorSubject(value: AuthenticationStatus.initial)
    var logoutAuthenticationStatus: Observable<AuthenticationStatus> {
        return _logoutAuthenticationStatus
            .asObservable()
    }

    var dismissing = PublishSubject<Void>()
    var dismissed: Observable<Void> {
        return dismissing
            .delay(.milliseconds(250), scheduler: MainScheduler.instance) // Allow some time for dismissing animation
    }

    var closeClick = PublishSubject<Void>()

    private let userDefaultsProvider: UserDefaultsProviderProtocol
    private let disposeBag = DisposeBag()

    private var spotIdToFilterBy: OWSpotId?

    init(filterBySpotId spotId: OWSpotId? = nil, userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        spotIdToFilterBy = spotId
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

private extension AuthenticationPlaygroundViewModel {
    // swiftlint:disable function_body_length
    func setupObservers() {
        // Different generic SSO selected
        selectedGenericSSOOptionIndex
            .do(onNext: { [weak self] _ in
                self?._genericSSOAuthenticationStatus.onNext(.initial)
            })
            .bind(to: _selectedGenericSSOOptionIndex)
            .disposed(by: disposeBag)

        _selectedGenericSSOOptionIndex
            .delay(.milliseconds(Metrics.delayInsertSSOPresetData), scheduler: MainScheduler.instance)
            .withLatestFrom(genericSSOOptions) { index, options -> GenericSSOAuthentication? in
                guard !options.isEmpty else {
                    DLog("There isn't any generic SSO preset")
                    return nil
                }
                return options[index]
            }
            .unwrap()
            .subscribe(onNext: { [weak self] genericSSOAuthentication in
                guard let self else { return }
                self.customUsername.onNext(genericSSOAuthentication.user.username)
                self.customPassword.onNext(genericSSOAuthentication.user.password)
                self.customSSOToken.onNext(genericSSOAuthentication.ssoToken)
            })
            .disposed(by: disposeBag)

        // Different Third-party SSO selected
        selectedThirdPartySSOOptionIndex
            .do(onNext: { [weak self] _ in
                self?._thirdPartySSOAuthenticationStatus.onNext(.initial)
            })
            .bind(to: _selectedThirdPartySSOOptionIndex)
            .disposed(by: disposeBag)

        // Bind SDK initialization toggle
        initializeSDKToggled
            .do(onNext: { [weak self] _ in
                self?._genericSSOAuthenticationStatus.onNext(.initial)
                self?._thirdPartySSOAuthenticationStatus.onNext(.initial)
            })
            .bind(to: shouldInitializeSDK)
            .disposed(by: disposeBag)

        // Bind automatically dismiss toggle (after successful login)
        automaticallyDismissToggled
            .do(onNext: { [weak self] _ in
                self?._genericSSOAuthenticationStatus.onNext(.initial)
                self?._thirdPartySSOAuthenticationStatus.onNext(.initial)
            })
            .bind(to: shouldAutomaticallyDismiss)
            .disposed(by: disposeBag)

        // Logout
        logoutPressed
            .do(onNext: { [weak self] _ in
                self?._thirdPartySSOAuthenticationStatus.onNext(.initial)
                self?._genericSSOAuthenticationStatus.onNext(.initial)
                self?._logoutAuthenticationStatus.onNext(.inProgress)
            })
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let authentication = OpenWeb.manager.authentication
                if shouldUseAsyncAwaitCallingMethod() {
                    Task { [weak self] in
                        do {
                            var loginStatus = try await authentication.userStatus()
                            DLog("Before logout \(loginStatus))")
                            try await authentication.logout()
                            self?._logoutAuthenticationStatus.onNext(.successful)
                            loginStatus = try await authentication.userStatus()
                            DLog("After logout \(loginStatus))")
                        } catch {
                            DLog("Logout error: \(error)")
                            self?._logoutAuthenticationStatus.onNext(.failed)
                        }
                    }

                } else {
                    authentication.userStatus { loginStatus in
                        DLog("Before logout \(loginStatus))")
                        authentication.logout { [weak self] result in
                            switch result {
                            case .success:
                                authentication.userStatus { loginStatus in
                                    DLog("After logout \(loginStatus))")
                                }
                                self?._logoutAuthenticationStatus.onNext(.successful)
                            case .failure(let error):
                                DLog("Logout error: \(error)")
                                self?._logoutAuthenticationStatus.onNext(.failed)
                            }
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        // Generic SSO authentication started
        genericSSOAuthenticatePressed
            .flatMapLatest { [weak self] _ -> Observable<Int> in
                // 1. Retrieving selected generic SSO
                guard let self else { return .empty() }
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
                self?._thirdPartySSOAuthenticationStatus.onNext(.initial)
                self?._logoutAuthenticationStatus.onNext(.initial)
            })
            .withLatestFrom(
                Observable.combineLatest(shouldInitializeSDK,
                                         customUsername,
                                         customPassword,
                                         customSSOToken)
            ) { genericSSO, latestValues in
                return (genericSSO, latestValues.0, latestValues.1, latestValues.2, latestValues.3)
            }
            .flatMapLatest { genericSSO, shouldInitializeSDK, customUsername, customPassword, customSSOToken -> Observable<GenericSSOAuthentication> in
                // 2. Initialize SDK with appropriate spotId if needed
                if shouldInitializeSDK {
                    var manager = OpenWeb.manager
                    manager.spotId = genericSSO.spotId
                }
                var genericSSO = genericSSO
                genericSSO.user.username = customUsername
                genericSSO.user.password = customPassword
                genericSSO.ssoToken = customSSOToken
                return Observable.just(genericSSO)
            }
            .flatMapLatest { [weak self] genericSSO -> Observable<(String, GenericSSOAuthentication)> in
                // 3. Login user if needed
                guard let self else { return.just(("", genericSSO)) }
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
                guard let self else { return Observable.empty() }
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
            guard let self else { return Observable.empty() }
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
                guard let self else { return Observable.empty() }
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

        // Third-party SSO authentication started
        thirdPartySSOAuthenticatePressed
            .flatMapLatest { [weak self] _ -> Observable<Int> in
                // 1. Retrieving selected Third-party SSO
                guard let self else { return .empty() }
                return self._selectedThirdPartySSOOptionIndex
                    .take(1)
            }
            .withLatestFrom(thirdPartySSOOptions) { index, options -> ThirdPartySSOAuthentication? in
                guard !options.isEmpty else {
                    DLog("There isn't any Third-party SSO preset")
                    return nil
                }
                return options[index]
            }
            .unwrap()
            .do(onNext: { [weak self] _ in
                self?._thirdPartySSOAuthenticationStatus.onNext(.inProgress)
                self?._genericSSOAuthenticationStatus.onNext(.initial)
                self?._logoutAuthenticationStatus.onNext(.initial)
            })
            .withLatestFrom(shouldInitializeSDK) { thirdPartySSO, shouldInitializeSDK -> ThirdPartySSOAuthentication in
                // 2. Initialize SDK with appropriate spotId if needed
                if shouldInitializeSDK {
                    var manager = OpenWeb.manager
                    manager.spotId = thirdPartySSO.spotId
                }
                return thirdPartySSO
            }
            .flatMapLatest { [weak self] thirdPartySSO -> Observable<String> in
                // 4. Perform SSO with token
                guard let self else { return Observable.empty() }
                return self.sso(provider: thirdPartySSO.provider, token: thirdPartySSO.token)
                    .observe(on: MainScheduler.instance)
                    .catchAndReturn(nil) // Keep the main subscription in case of an error
                    .do(onNext: { [weak self] value in
                        if value == nil {
                            self?._thirdPartySSOAuthenticationStatus.onNext(.failed)
                        }
                    })
                    .unwrap()
            }
            .do(onNext: { [weak self] _ in
                self?._thirdPartySSOAuthenticationStatus.onNext(.successful)
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

        // Close clicked
        closeClick
            .bind(to: dismissVC)
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

    func sso(provider: OWSSOProvider, token: String) -> Observable<String?> {
        return Observable.create { observer in
            let authentication = OpenWeb.manager.authentication
            authentication.sso(.usingProvider(provider: provider, token: token, completion: { result in
                switch result {
                case .success(let ssoProviderModel):
                    observer.onNext(ssoProviderModel.userId)
                    observer.onCompleted()
                case .failure(let error):
                    DLog("Failed in 'sso(provider: , token: )' with error: \(error)")
                    observer.onError(error)
                }
            }))

            return Disposables.create()
        }
    }

    func login(user: UserAuthentication) -> Observable<String?> {
        return Observable.create { observer in
            DemoUserAuthentication.logIn(with: user.username, password: user.password) { token, error in
                guard let token else {
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
                guard let codeB else {
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

    func shouldUseAsyncAwaitCallingMethod() -> Bool {
        return SampleAppCallingMethod.asyncAwait == userDefaultsProvider.get(key: .callingMethodOption, defaultValue: .default)
    }
}
