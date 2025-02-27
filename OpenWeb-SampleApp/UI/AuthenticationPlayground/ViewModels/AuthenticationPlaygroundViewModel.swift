//
//  AuthenticationPlaygroundNewAPIViewModel.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 16/01/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import Combine
import CombineExt
import Alamofire
import OpenWebSDK

protocol AuthenticationPlaygroundViewModelingInputs {
    var selectedGenericSSOOptionIndex: PassthroughSubject<Int, Never> { get }
    var selectedThirdPartySSOOptionIndex: PassthroughSubject<Int, Never> { get }
    var logoutPressed: PassthroughSubject<Void, Never> { get }
    var genericSSOAuthenticatePressed: PassthroughSubject<Void, Never> { get }
    var thirdPartySSOAuthenticatePressed: PassthroughSubject<Void, Never> { get }
    var initializeSDKToggled: PassthroughSubject<Bool, Never> { get }
    var automaticallyDismissToggled: PassthroughSubject<Bool, Never> { get }
    var dismissing: PassthroughSubject<Void, Never> { get }
    var closeClick: PassthroughSubject<Void, Never> { get }
    var customSSOToken: CurrentValueSubject<String, Never> { get }
    var customUsername: CurrentValueSubject<String, Never> { get }
    var customPassword: CurrentValueSubject<String, Never> { get }
}

protocol AuthenticationPlaygroundViewModelingOutputs {
    var title: String { get }
    var genericSSOOptions: AnyPublisher<[GenericSSOAuthentication], Never> { get }
    var thirdPartySSOOptions: AnyPublisher<[ThirdPartySSOAuthentication], Never> { get }
    var genericSSOAuthenticationStatus: AnyPublisher<AuthenticationStatus, Never> { get }
    var thirdPartySSOAuthenticationStatus: AnyPublisher<AuthenticationStatus, Never> { get }
    var logoutAuthenticationStatus: AnyPublisher<AuthenticationStatus, Never> { get }
    var dismissVC: PassthroughSubject<Void, Never> { get }
    var dismissed: AnyPublisher<Void, Never> { get }
    var customSSOTokenChanged: AnyPublisher<String, Never> { get }
    var customUsernameChanged: AnyPublisher<String, Never> { get }
    var customPasswordChanged: AnyPublisher<String, Never> { get }
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

    private let _selectedGenericSSOOptionIndex = CurrentValueSubject(value: 0)
    var selectedGenericSSOOptionIndex = PassthroughSubject<Int, Never>()

    private let _selectedThirdPartySSOOptionIndex = CurrentValueSubject(value: 0)
    var selectedThirdPartySSOOptionIndex = PassthroughSubject<Int, Never>()

    private let shouldInitializeSDK = CurrentValueSubject(value: false)
    var initializeSDKToggled = PassthroughSubject<Bool, Never>()

    private let shouldAutomaticallyDismiss = CurrentValueSubject(value: true)
    var automaticallyDismissToggled = PassthroughSubject<Bool, Never>()

    var logoutPressed = PassthroughSubject<Void, Never>()

    var dismissVC = PassthroughSubject<Void, Never>()

    var genericSSOAuthenticatePressed = PassthroughSubject<Void, Never>()
    var thirdPartySSOAuthenticatePressed = PassthroughSubject<Void, Never>()

    var customSSOToken = CurrentValueSubject<String, Never>("")
    var customUsername = CurrentValueSubject<String, Never>("")
    var customPassword = CurrentValueSubject<String, Never>("")

    lazy var customSSOTokenChanged: AnyPublisher<String, Never> = {
        return customSSOToken
            .eraseToAnyPublisher()
    }()

    lazy var customUsernameChanged: AnyPublisher<String, Never> = {
        return customUsername
            .eraseToAnyPublisher()
    }()

    lazy var customPasswordChanged: AnyPublisher<String, Never> = {
        return customPassword
            .eraseToAnyPublisher()
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

    private lazy var _genericSSOOptions = CurrentValueSubject(value: genericSSOAuthenticationModels)
    var genericSSOOptions: AnyPublisher<[GenericSSOAuthentication], Never> {
        return _genericSSOOptions
            .eraseToAnyPublisher()
    }

    lazy var thirdPartySSOAuthenticationModels: [ThirdPartySSOAuthentication] = {
        var models = ThirdPartySSOAuthentication.mockModels

        if let spotId = spotIdToFilterBy {
            models = models.filter { $0.spotId == spotId }
        }

        return models
    }()

    private lazy var _thirdPartySSOOptions = CurrentValueSubject(value: thirdPartySSOAuthenticationModels)
    var thirdPartySSOOptions: AnyPublisher<[ThirdPartySSOAuthentication], Never> {
        return _thirdPartySSOOptions
            .eraseToAnyPublisher()
    }

    private let _genericSSOAuthenticationStatus = CurrentValueSubject(value: AuthenticationStatus.initial)
    var genericSSOAuthenticationStatus: AnyPublisher<AuthenticationStatus, Never> {
        return _genericSSOAuthenticationStatus
            .eraseToAnyPublisher()
    }

    private let _thirdPartySSOAuthenticationStatus = CurrentValueSubject(value: AuthenticationStatus.initial)
    var thirdPartySSOAuthenticationStatus: AnyPublisher<AuthenticationStatus, Never> {
        return _thirdPartySSOAuthenticationStatus
            .eraseToAnyPublisher()
    }

    private let _logoutAuthenticationStatus = CurrentValueSubject(value: AuthenticationStatus.initial)
    var logoutAuthenticationStatus: AnyPublisher<AuthenticationStatus, Never> {
        return _logoutAuthenticationStatus
            .eraseToAnyPublisher()
    }

    var dismissing = PassthroughSubject<Void, Never>()
    var dismissed: AnyPublisher<Void, Never> {
        return dismissing
            .delay(for: .milliseconds(250), scheduler: DispatchQueue.main) // Allow some time for dismissing animation
            .eraseToAnyPublisher()
    }

    var closeClick = PassthroughSubject<Void, Never>()

    private let userDefaultsProvider: UserDefaultsProviderProtocol
    private var cancellables = Set<AnyCancellable>()

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
            .handleEvents(receiveOutput: { [weak self] _ in
                self?._genericSSOAuthenticationStatus.send(.initial)
            })
            .bind(to: _selectedGenericSSOOptionIndex)
            .store(in: &cancellables)

        _selectedGenericSSOOptionIndex
            .delay(for: .milliseconds(Metrics.delayInsertSSOPresetData), scheduler: RunLoop.main)
            .withLatestFrom(genericSSOOptions) { index, options -> GenericSSOAuthentication? in
                guard !options.isEmpty else {
                    DLog("There isn't any generic SSO preset")
                    return nil
                }
                return options[index]
            }
            .unwrap()
            .sink { [weak self] genericSSOAuthentication in
                guard let self else { return }
                self.customUsername.send(genericSSOAuthentication.user.username)
                self.customPassword.send(genericSSOAuthentication.user.password)
                self.customSSOToken.send(genericSSOAuthentication.ssoToken)
            }
            .store(in: &cancellables)

        // Different Third-party SSO selected
        selectedThirdPartySSOOptionIndex
            .handleEvents(receiveOutput: { [weak self] _ in
                self?._thirdPartySSOAuthenticationStatus.send(.initial)
            })
            .bind(to: _selectedThirdPartySSOOptionIndex)
            .store(in: &cancellables)

        // Bind SDK initialization toggle
        initializeSDKToggled
            .handleEvents(receiveOutput: { [weak self] _ in
                self?._genericSSOAuthenticationStatus.send(.initial)
                self?._thirdPartySSOAuthenticationStatus.send(.initial)
            })
            .bind(to: shouldInitializeSDK)
            .store(in: &cancellables)

        // Bind automatically dismiss toggle (after successful login)
        automaticallyDismissToggled
            .handleEvents(receiveOutput: { [weak self] _ in
                self?._genericSSOAuthenticationStatus.send(.initial)
                self?._thirdPartySSOAuthenticationStatus.send(.initial)
            })
            .bind(to: shouldAutomaticallyDismiss)
            .store(in: &cancellables)

        // Logout
        logoutPressed
            .handleEvents(receiveOutput: { [weak self] _ in
                self?._thirdPartySSOAuthenticationStatus.send(.initial)
                self?._genericSSOAuthenticationStatus.send(.initial)
                self?._logoutAuthenticationStatus.send(.inProgress)
            })
            .sink { [weak self] in
                guard let self else { return }
                let authentication = OpenWeb.manager.authentication
                if shouldUseAsyncAwaitCallingMethod() {
                    Task { [weak self] in
                        do {
                            var loginStatus = try await authentication.userStatus()
                            DLog("Before logout \(loginStatus))")
                            try await authentication.logout()
                            self?._logoutAuthenticationStatus.send(.successful)
                            loginStatus = try await authentication.userStatus()
                            DLog("After logout \(loginStatus))")
                        } catch {
                            DLog("Logout error: \(error)")
                            self?._logoutAuthenticationStatus.send(.failed)
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
                                self?._logoutAuthenticationStatus.send(.successful)
                            case .failure(let error):
                                DLog("Logout error: \(error)")
                                self?._logoutAuthenticationStatus.send(.failed)
                            }
                        }
                    }
                }
            }
            .store(in: &cancellables)

        // Generic SSO authentication started
        genericSSOAuthenticatePressed
            .flatMapLatest { [weak self] _ -> AnyPublisher<Int, Never> in
                // 1. Retrieving selected generic SSO
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self._selectedGenericSSOOptionIndex
                    .prefix(1)
                    .eraseToAnyPublisher()
            }
            .withLatestFrom(genericSSOOptions) { index, options -> GenericSSOAuthentication? in
                guard !options.isEmpty else {
                    DLog("There isn't any generic SSO preset")
                    return nil
                }
                return options[index]
            }
            .unwrap()
            .handleEvents(receiveOutput: { [weak self] _ in
                self?._genericSSOAuthenticationStatus.send(.inProgress)
                self?._thirdPartySSOAuthenticationStatus.send(.initial)
                self?._logoutAuthenticationStatus.send(.initial)
            })
            .withLatestFrom(
                Publishers.CombineLatest4(shouldInitializeSDK,
                                          customUsername,
                                          customPassword,
                                          customSSOToken)
            ) { genericSSO, latestValues in
                return (genericSSO, latestValues.0, latestValues.1, latestValues.2, latestValues.3)
            }
            .flatMapLatest { genericSSO, shouldInitializeSDK, customUsername, customPassword, customSSOToken -> AnyPublisher<GenericSSOAuthentication, Never> in
                // 2. Initialize SDK with appropriate spotId if needed
                if shouldInitializeSDK {
                    let manager = OpenWeb.manager
                    manager.spotId = genericSSO.spotId
                }
                var genericSSO = genericSSO
                genericSSO.user.username = customUsername
                genericSSO.user.password = customPassword
                genericSSO.ssoToken = customSSOToken
                return Just(genericSSO).eraseToAnyPublisher()
            }
            .flatMapLatest { [weak self] genericSSO -> AnyPublisher<(String, GenericSSOAuthentication), Never> in
                // 3. Login user if needed
                guard let self else { return Just(("", genericSSO)).eraseToAnyPublisher() }
                return self.login(user: genericSSO.user)
                    .receive(on: DispatchQueue.main)
                    .replaceError(with: nil) // Keep the main subscription in case of an error
                    .handleEvents(receiveOutput: { [weak self] value in
                        if value == nil {
                            self?._genericSSOAuthenticationStatus.send(.failed)
                        }
                    })
                    .unwrap()
                    .map { ($0, genericSSO) }
                    .eraseToAnyPublisher()
            }
            .flatMapLatest { [weak self] token, genericSSO -> AnyPublisher<(String, String, GenericSSOAuthentication), Never> in
                // 4. Start SSO
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self.startSSO()
                    .receive(on: DispatchQueue.main)
                    .replaceError(with: nil) // Keep the main subscription in case of an error
                    .handleEvents(receiveOutput: { [weak self] value in
                        if value == nil {
                            self?._genericSSOAuthenticationStatus.send(.failed)
                        }
                    })
                    .unwrap()
                    .map { ($0, token, genericSSO) }
                    .eraseToAnyPublisher()
            }
            .flatMapLatest { [weak self] codeA, token, genericSSO -> AnyPublisher<String, Never> in
            // 5. Retrieving Code B
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self.codeB(codeA: codeA, token: token, genericSSO: genericSSO)
                    .receive(on: DispatchQueue.main)
                    .replaceError(with: nil) // Keep the main subscription in case of an error
                    .handleEvents(receiveOutput: { [weak self] value in
                        if value == nil {
                            self?._genericSSOAuthenticationStatus.send(.failed)
                        }
                    })
                    .unwrap()
            }
            .flatMapLatest { [weak self] codeB -> AnyPublisher<Void, Never> in
                // 6. Complete SSO
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self.completeSSO(codeB: codeB)
                    .receive(on: DispatchQueue.main)
                    .replaceError(with: nil)
                    .handleEvents(receiveOutput: { [weak self] value in
                        if value == nil {
                            self?._genericSSOAuthenticationStatus.send(.failed)
                        }
                    })
                    .unwrap()
                    .voidify()
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?._genericSSOAuthenticationStatus.send(.successful)
            })
            .withLatestFrom(shouldAutomaticallyDismiss)
            .filter { $0 == true }
            .delay(for: .milliseconds(Metrics.delayUntilDismissVC), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                // 7. Rx back to the view layer to dismiss itself
                self?.outputs.dismissVC.send()
            }
            .store(in: &cancellables)

        // Third-party SSO authentication started
        thirdPartySSOAuthenticatePressed
            .flatMapLatest { [weak self] _ -> AnyPublisher<Int, Never> in
                // 1. Retrieving selected Third-party SSO
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self._selectedThirdPartySSOOptionIndex
                    .prefix(1)
                    .eraseToAnyPublisher()
            }
            .withLatestFrom(thirdPartySSOOptions) { index, options -> ThirdPartySSOAuthentication? in
                guard !options.isEmpty else {
                    DLog("There isn't any Third-party SSO preset")
                    return nil
                }
                return options[index]
            }
            .unwrap()
            .handleEvents(receiveOutput: { [weak self] _ in
                self?._thirdPartySSOAuthenticationStatus.send(.inProgress)
                self?._genericSSOAuthenticationStatus.send(.initial)
                self?._logoutAuthenticationStatus.send(.initial)
            })
            .withLatestFrom(shouldInitializeSDK) { thirdPartySSO, shouldInitializeSDK -> ThirdPartySSOAuthentication in
                // 2. Initialize SDK with appropriate spotId if needed
                if shouldInitializeSDK {
                    let manager = OpenWeb.manager
                    manager.spotId = thirdPartySSO.spotId
                }
                return thirdPartySSO
            }
            .flatMapLatest { [weak self] thirdPartySSO -> AnyPublisher<String, Never> in
                // 4. Perform SSO with token
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self.sso(provider: thirdPartySSO.provider, token: thirdPartySSO.token)
                    .receive(on: DispatchQueue.main)
                    .replaceError(with: nil) // Keep the main subscription in case of an error
                    .handleEvents(receiveOutput: { [weak self] value in
                        if value == nil {
                            self?._thirdPartySSOAuthenticationStatus.send(.failed)
                        }
                    })
                    .unwrap()
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?._thirdPartySSOAuthenticationStatus.send(.successful)
            })
            .withLatestFrom(shouldAutomaticallyDismiss)
            .filter { $0 == true }
            .delay(for: .milliseconds(Metrics.delayUntilDismissVC), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                // 5. Rx back to the view layer to dismiss itself
                self?.outputs.dismissVC.send()
            }
            .store(in: &cancellables)

        // Close clicked
        closeClick
            .bind(to: dismissVC)
            .store(in: &cancellables)
    }
    // swiftlint:enable function_body_length

    func startSSO() -> AnyPublisher<String?, OWError> {
        return AnyPublisher<String?, OWError>.create { observer in
            let authentication = OpenWeb.manager.authentication
            authentication.sso(.start(completion: { result in
                switch result {
                case .success(let startSSOModel):
                    observer.send(startSSOModel.codeA)
                    observer.send(completion: .finished)
                case .failure(let error):
                    DLog("Failed in 'startSSO' with error: \(error)")
                    observer.send(completion: .failure(error))
                }
            }))

            return AnyCancellable {}
        }
    }

    func completeSSO(codeB: String) -> AnyPublisher<String?, OWError> {
        return AnyPublisher<String?, OWError>.create { observer in
            let authentication = OpenWeb.manager.authentication
            authentication.sso(.complete(codeB: codeB, completion: { result in
                switch result {
                case .success(let completeSSOModel):
                    observer.send(completeSSOModel.userId)
                    observer.send(completion: .finished)
                case .failure(let error):
                    DLog("Failed in 'completeSSO(codeB:)' with error: \(error)")
                    observer.send(completion: .failure(error))
                }
            }))

            return AnyCancellable {}
        }
    }

    func sso(provider: OWSSOProvider, token: String) -> AnyPublisher<String?, OWError> {
        return AnyPublisher<String?, OWError>.create { observer in
            let authentication = OpenWeb.manager.authentication
            authentication.sso(.usingProvider(provider: provider, token: token, completion: { result in
                switch result {
                case .success(let ssoProviderModel):
                    observer.send(ssoProviderModel.userId)
                    observer.send(completion: .finished)
                case .failure(let error):
                    DLog("Failed in 'sso(provider: , token: )' with error: \(error)")
                    observer.send(completion: .failure(error))
                }
            }))

            return AnyCancellable {}
        }
    }

    func login(user: UserAuthentication) -> AnyPublisher<String?, Error> {
        return AnyPublisher<String?, Error>.create { observer in
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

    func codeB(codeA: String, token: String, genericSSO: GenericSSOAuthentication) -> AnyPublisher<String?, Error> {
        return AnyPublisher<String?, Error>.create { observer in
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

    func shouldUseAsyncAwaitCallingMethod() -> Bool {
        return SampleAppCallingMethod.asyncAwait == userDefaultsProvider.get(key: .callingMethodOption, defaultValue: .default)
    }
}
