//
//  OWAuthenticationManager.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 12/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWAuthenticationManagerProtocol {
    var userAuthenticationStatus: Observable<OWInternalUserAuthenticationStatus> { get }
    var currentAuthenticationLevelAvailability: Observable<OWAuthenticationLevelAvailability> { get }
    var activeUserAvailability: Observable<OWUserAvailability> { get }

    var networkCredentials: OWNetworkSessionCredentials { get }
    func updateNetworkCredentials(from response: HTTPURLResponse)

    func ifNeededTriggerAuthenticationUI(for action: OWUserAction) -> Observable<Bool>
    func waitForAuthentication(for action: OWUserAction, waitForBlockingCompletions: Bool) -> Observable<Bool>

    func userHasAuthenticationLevel(for actions: [OWUserAction]) -> Observable<[OWUserAction: Bool]>
    func userHasAuthenticationLevel(for action: OWUserAction) -> Observable<Bool>

    func enterAuthenticationRecoveryState()
    func finishAuthenticationRecovery(with authenticationRecovery: OWAuthenticationRecoveryResult)
    func logout() -> Observable<Void>
    func startSSO() -> Observable<OWSSOStartModel>
    func completeSSO(codeB: String) -> Observable<OWSSOCompletionModel>
    func ssoAuthenticate(withProvider provider: OWSSOProvider, token: String) -> Observable<OWSSOProviderModel>

    // Those methods exposed since we are testing multiple SpotIds inside our SampleApp - therefore we must considered the "current" spotId
    func prepare(forSpotId spotId: OWSpotId)
    func change(newSpotId spotId: OWSpotId)
}

extension OWAuthenticationManagerProtocol {
    func waitForAuthentication(for action: OWUserAction) -> Observable<Bool> {
        return self.waitForAuthentication(for: action, waitForBlockingCompletions: true)
    }
}

class OWAuthenticationManager: OWAuthenticationManagerProtocol {

    private typealias OWUserAvailabilityMapper = [OWSpotId: OWUserAvailability]
    private unowned let manager: OWManagerProtocol & OWManagerInternalProtocol
    private unowned let servicesProvider: OWSharedServicesProviding
    private let randomGenerator: OWRandomGeneratorProtocol
    private let scheduler: SchedulerType

    private struct Metrics {
        static let maxSSORecoveryTime: Int = 30 // In seconds
        static let maxAttemptsToObtainNewUser: Int = 3
        static let delayToObtainUser: Int = 1000 // In ms
    }

    init (manager: OWManagerProtocol & OWManagerInternalProtocol = OWManager.manager,
          servicesProvider: OWSharedServicesProviding,
          randomGenerator: OWRandomGeneratorProtocol = OWRandomGenerator(),
          scheduler: SchedulerType = SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: "OpenWebSDKAuthenticationManagerQueue")) {
        self.manager = manager
        self.servicesProvider = servicesProvider
        self.scheduler = scheduler
        self.randomGenerator = randomGenerator

        loadGeneralPersistence()
    }

    private var _networkCredentials = OWNetworkSessionCredentials.none
    var networkCredentials: OWNetworkSessionCredentials {
        return _networkCredentials
    }

    private let _activeUserAvailability = BehaviorSubject<OWUserAvailability>(value: .notAvailable)
    var activeUserAvailability: Observable<OWUserAvailability> {
        return _activeUserAvailability
            .distinctUntilChanged()
            .share(replay: 1)
    }

    private let _userAuthenticationStatus = BehaviorSubject<OWInternalUserAuthenticationStatus>(value: .notAutenticated)
    var userAuthenticationStatus: Observable<OWInternalUserAuthenticationStatus> {
        return _userAuthenticationStatus
            .distinctUntilChanged()
            .share(replay: 1)
    }

    var currentAuthenticationLevelAvailability: Observable<OWAuthenticationLevelAvailability> {
        return userAuthenticationStatus
            .map { $0.authenticationLevelAvailability }
    }
}

// Authentication by actions (OWUserAction) related methods
extension OWAuthenticationManager {
    func ifNeededTriggerAuthenticationUI(for action: OWUserAction) -> Observable<Bool> {
        return self.shouldShowAuthenticationUI(for: action)
            .do(onNext: { [weak self] shouldShow in
                guard shouldShow, let self = self,
                      let routeringModeProtocol = self.manager.ui as? OWRouteringModeProtocol,
                      let authenticationUILayer = self.manager.ui.authenticationUI as? OWUIAuthenticationInternalProtocol else { return }
                let blockerService = self.servicesProvider.blockerServicing()
                let blockerAction = OWDefaultBlockerAction(blockerType: .authentication)
                blockerService.add(blocker: blockerAction)

                let routeringMode: OWRouteringMode

                var router: OWRoutering?
                if case let OWRouteringModeInternal.routering(routering) = routeringModeProtocol.activeRouteringMode,
                   let navController = routering.navigationController {
                    routeringMode = .flow(navigationController: navController)
                    router = routering
                } else {
                   routeringMode = .none
                }

                // For Pre-conversation present mode where the VC not started yet
                if let router = router, router.isEmpty() {
                    let authDismiss = PublishSubject<Void>()
                    let vm = OWNavigationPlaceholderViewModel(onFirstActualVC: { publisherAuthVC in
                        router.start()
                        // Since the placeholder VC is being removed once the publisher VC is on router, we need to set the completion to the correct VC
                        router.setCompletion(for: publisherAuthVC, dismissCompletion: authDismiss)
                    })
                    let vc = OWNavigationPlaceholderVC(viewModel: vm)
                    router.setRoot(vc, animated: false, dismissCompletion: nil)
                    // Once publisher auth VC is really dismissed (from our router), complete blocking
                    _ = authDismiss
                        .take(1)
                        .asObservable()
                        .subscribe(onNext: {
                            blockerAction.completion()
                        })

                    authenticationUILayer.triggerPublisherDisplayAuthenticationFlow(routeringMode: routeringMode, completion: {})
                } else {
                    authenticationUILayer.triggerPublisherDisplayAuthenticationFlow(routeringMode: routeringMode, completion: blockerAction.completion)
                }
            })
    }

    func userHasAuthenticationLevel(for actions: [OWUserAction]) -> Observable<[OWUserAction: Bool]> {
        let actionAndAuthenticationLevelTupple = actions.map { action in
            return userHasAuthenticationLevel(for: action)
                .map { (action, $0) }
        }

        let actionsAuthenticationLevelObservable = Observable.combineLatest(actionAndAuthenticationLevelTupple)

        return actionsAuthenticationLevelObservable.map { actionsAuthenticationLevel in
            var result: [OWUserAction: Bool] = [:]
            actionsAuthenticationLevel.forEach { result[$0.0] = $0.1 }
            return result
        }
    }

    func userHasAuthenticationLevel(for action: OWUserAction) -> Observable<Bool> {
        return self.currentAuthenticationLevelAvailability
            .map { authenticationLevelAvailability -> OWAuthenticationLevel? in
                switch authenticationLevelAvailability {
                case .level(let level):
                    return level
                case .pending:
                    return nil
                }
            }
            .unwrap()
            .flatMapLatest { [weak self] level -> Observable<(OWAuthenticationLevel, OWAuthenticationLevel)> in
                guard let self = self else { return .empty() }
                return self.requiredAuthenticationLevel(for: action)
                    .map { (level, $0) }
            }
            .map { currentlevel, requiredlevel in
                return currentlevel.level >= requiredlevel.level
            }
    }

    func waitForAuthentication(for action: OWUserAction, waitForBlockingCompletions: Bool = true) -> Observable<Bool> {
        let authenticationForActionObserver: Observable<Bool>

        if waitForBlockingCompletions {
            authenticationForActionObserver = self.servicesProvider.blockerServicing().waitForNonBlocker(for: [.authentication, .renewAuthentication])
                .withLatestFrom(self.userHasAuthenticationLevel(for: action))
        } else {
            authenticationForActionObserver = self.requiredAuthenticationLevel(for: action)
                .flatMap { [weak self] requiredlevel -> Observable<Void> in
                    guard let self = self else { return .empty() }
                    return self.waitForAuthenticationLevel(aboveOrEqual: requiredlevel)
                        .voidify()
                }
                .map { true }
        }

        return authenticationForActionObserver
            .take(1)
    }
}

// Network related methods
extension OWAuthenticationManager {
    func updateNetworkCredentials(from response: HTTPURLResponse) {
        let headers = response.allHeaderFields

        let extractedGUID = OWHeaderExtractor.default.extract(headerType: .guid, from: headers)
        let extractedAuthorization = OWHeaderExtractor.default.extract(headerType: .authorization, from: headers)
        let extractedOpenWebToken = OWHeaderExtractor.default.extract(headerType: .openWebToken, from: headers)

        // 1. Log an error if the returned guid from the server is different than what we have
        if let serverGUID = extractedGUID, let localGUID = _networkCredentials.guid, serverGUID != localGUID {
            // TODO: We should also report an error here once we will have an error reporting or event for this
            let logger = servicesProvider.logger()
            let logMessage = "Returned GUID from server: \(serverGUID) is different from local GUID: \(localGUID)"
            logger.log(level: .error, logMessage)
        }

        // 2. Create new `Authorization` and `OpenWebToken` if returned from server
        let newAuthorization = extractedAuthorization ?? _networkCredentials.authorization
        let newOpenWebToken = extractedOpenWebToken ?? _networkCredentials.openwebToken

        // 3. Update and save `Authorization` and `OpenWebToken` if they are actually different than what we previously had
        if (newAuthorization != _networkCredentials.authorization) || (newOpenWebToken != _networkCredentials.openwebToken) {
            // Update credentials and persistence only if needed
            let newCredentials = OWNetworkSessionCredentials(guid: _networkCredentials.guid,
                                                             openwebToken: newOpenWebToken,
                                                             authorization: newAuthorization)

            self._networkCredentials = newCredentials
            update(credentials: newCredentials)
        }
    }

    private func obtainNetworkUserIfNeeded(forSpotId spotId: OWSpotId) {
        _ = self._userAuthenticationStatus
            .take(1)
            .map { internalStatus -> Bool in
                guard let status = internalStatus.toOWUserAuthenticationStatus() else {
                    // Recovering status or something which related to SSO
                    return false
                }

                let shouldObtainUser = (status == .notAutenticated || status == .guest)
                return shouldObtainUser
            }
            .filter { $0 } // We would like to obtain user only in non SSO related statuses, otherwise `OWAuthorizationRecoveryService` class will take care for the rest
            .flatMap { [weak self] _ -> Observable<SPUser> in
                guard let self = self else { return .empty() }
                return self.retrieveNetworkNewUser()
            }
            .subscribe()
    }

    private func triggerNetworkNewUser(forSpotId spotId: OWSpotId) {
        _ = self.retrieveNetworkNewUser()
            .subscribe()
    }

    private func retrieveNetworkNewUser() -> Observable<SPUser> {
        let configurationService = servicesProvider.spotConfigurationService()

        return configurationService.config(spotId: OpenWeb.manager.spotId)
            .observe(on: scheduler)
            .take(1) // Here we are simply waiting for the config first / ensuring such exist for the specific spotId
            .flatMap { [weak self] _ -> Observable<SPUser> in
                guard let self = self else { return .empty() }
                let user = self.servicesProvider.networkAPI().user
                return user
                    .userData()
                    .response
                    .observe(on: self.scheduler)
                    .exponentialRetry(maxAttempts: Metrics.maxAttemptsToObtainNewUser, millisecondsDelay: Metrics.delayToObtainUser) // Adding retry as it is critical we will succeed here
                    .take(1) // No need to dispose
            }
            .do(onNext: { [weak self] newUser in
                guard let self = self else { return }
                let authenticationRecoveryResult: OWAuthenticationRecoveryResult = .newAuthentication(user: newUser)
                self.finishAuthenticationRecovery(with: authenticationRecoveryResult)
            })
    }

}

// Authentication SSO related methods
extension OWAuthenticationManager {
    func enterAuthenticationRecoveryState() {
        // Remove `Authorization` header first
        let newCredentials = OWNetworkSessionCredentials(guid: _networkCredentials.guid,
                                                         openwebToken: _networkCredentials.openwebToken,
                                                         authorization: nil)
        update(credentials: newCredentials)

        _ = userAuthenticationStatus
            .take(1)
            .subscribe(onNext: { [weak self] status in
                guard let self = self else { return }
                if case OWInternalUserAuthenticationStatus.ssoLoggedIn(userId: let userId) = status {
                    // Entering SSO recovering status
                    self._userAuthenticationStatus.onNext(.ssoRecovering(userId: userId))
                    self.ensureSSORecoveryStatus(for: userId)
                } else {
                    // Clear any user if there was
                    self.update(userAvailability: .notAvailable)
                    self._userAuthenticationStatus.onNext(.notAutenticated)
                }
            })
    }

    func finishAuthenticationRecovery(with authenticationRecovery: OWAuthenticationRecoveryResult) {
        switch authenticationRecovery {
        case .authenticationShouldRenew(user: let user):
            guard let authenticationLayer = self.manager.authentication as? OWAuthenticationInternalProtocol,
                  let userId = user.userId else { return }
            let blockerService = self.servicesProvider.blockerServicing()
            let blockerAction = OWDefaultBlockerAction(blockerType: .renewAuthentication)
            blockerService.add(blocker: blockerAction)
            authenticationLayer.triggerRenewSSO(userId: userId, completion: blockerAction.completion)
        case .newAuthentication(user: let user):
            self.update(userAvailability: .user(user))
            self._userAuthenticationStatus.onNext(.guest(userId: user.userId ?? ""))
        }
    }

    func logout() -> Observable<Void> {
        let networkAuthentication = servicesProvider.networkAPI().authentication

        return networkAuthentication
            .logout()
            .response
            .take(1)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                let newCredentials = OWNetworkSessionCredentials(guid: self._networkCredentials.guid,
                                                                 openwebToken: self._networkCredentials.openwebToken,
                                                                 authorization: nil)
                self.update(credentials: newCredentials)
            })
            .withLatestFrom(_userAuthenticationStatus)
            .do(onNext: { [weak self] currentAuthenticationStatus in
                // Do not update status to .notAutenticated if we are sso recovering
                if case .ssoRecovering = currentAuthenticationStatus { return }
                guard let self = self else { return }

                self.update(userAvailability: .notAvailable)
                self._userAuthenticationStatus.onNext(.notAutenticated)
            })
            .flatMapLatest { [weak self] currentAuthenticationStatus -> Observable<Void> in
                guard let self = self else { return .empty() }
                if case .ssoRecovering = currentAuthenticationStatus { return Observable.just(()) }
                return self.retrieveNetworkNewUser()
                    .take(1)
                    .voidify()
            }
    }

    func startSSO() -> Observable<OWSSOStartModel> {
        return _activeUserAvailability
            .take(1)
            .flatMap { [weak self] userAvailablity -> Observable<Void> in
                guard let self = self else { return .empty() }
                // 1. Logout current user if needed
                if case .user = userAvailablity {
                    return self.logout()
                } else {
                    return .just(())
                }
            }
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                // 2. Login (usually will provide a guest user))
                let networkAuthentication = self.servicesProvider.networkAPI().authentication
                return networkAuthentication
                    .login()
                    .response
                    .withLatestFrom(self._userAuthenticationStatus) { ($0, $1) }
                    .do(onNext: { [weak self] user, currentAuthenticationStatus in
                        guard let self = self else { return }
                        // Do not update user while we are sso recovering
                        if case .ssoRecovering = currentAuthenticationStatus { return }

                        self.update(userAvailability: .user(user))
                        self._userAuthenticationStatus.onNext(.guest(userId: user.userId ?? ""))
                    })
                    .voidify()
            }
            .flatMap { [weak self] _ -> Observable<OWSSOStartResponse> in
                guard let self = self else { return .empty() }
                // 2. Start SSO
                guard let authorization = self._networkCredentials.authorization else { return .error(OWError.ssoStart)}
                let networkAuthentication = self.servicesProvider.networkAPI().authentication
                return networkAuthentication
                    .ssoStart(secret: authorization)
                    .response
            }
            .map { $0.toSSOStartModel() }
    }

    func completeSSO(codeB: String) -> Observable<OWSSOCompletionModel> {
        return userAuthenticationStatus
            .take(1)
            .flatMapLatest { authenticationStatus -> Observable<Void> in
                // 1. Make sure not already logged in
                if case .ssoLoggedIn = authenticationStatus {
                    return .error(OWError.alreadyLoggedIn)
                } else {
                    return .just(())
                }
            }
            .flatMapLatest { [weak self] _ -> Observable<OWSSOCompletionResponse> in
                guard let self = self else { return .empty() }
                // 2. Proceed with SSO complete
                let networkAuthentication = self.servicesProvider.networkAPI().authentication
                return networkAuthentication
                    .ssoComplete(codeB: codeB)
                    .response
                    .do(onNext: { [weak self] ssoCompletionResponse  in
                        guard let self = self else { return }
                        let user = ssoCompletionResponse.user
                        self.update(userAvailability: .user(user))
                        self._userAuthenticationStatus.onNext(.ssoLoggedIn(userId: user.userId ?? ""))
                    })
            }
            .map { response -> OWSSOCompletionModel? in
                return response.toSSOCompletionModel()
            }
            .unwrap()
    }

    func ssoAuthenticate(withProvider provider: OWSSOProvider, token: String) -> Observable<OWSSOProviderModel> {
        return userAuthenticationStatus
            .take(1)
            .flatMap { authenticationStatus -> Observable<Void> in
                // 1. Make sure not already logged in
                if case .guest = authenticationStatus {
                    return .just(())
                } else if authenticationStatus == .notAutenticated {
                    return .just(())
                }

                return .error(OWError.alreadyLoggedIn)
            }
            .flatMap { [weak self] _ -> Observable<OWSSOProviderResponse> in
                guard let self = self else { return .empty() }
                // 2. Proceed with SSO complete
                let networkAuthentication = self.servicesProvider.networkAPI().authentication
                return networkAuthentication
                    .ssoAuthenticate(withProvider: provider, token: token)
                    .response
            }
            .do(onNext: { [weak self] ssoProviderResponse  in
                guard let self = self else { return }
                let user = ssoProviderResponse.user
                self.update(userAvailability: .user(user))
                self._userAuthenticationStatus.onNext(.ssoLoggedIn(userId: user.userId ?? ""))
            })
            .map { response -> OWSSOProviderModel? in
                return response.toSSOProviderModel()
            }
            .unwrap()
    }
}

// Persistence related methods
extension OWAuthenticationManager {
    func prepare(forSpotId spotId: OWSpotId) {
        loadPersistence(forSpotId: spotId)
        obtainNetworkUserIfNeeded(forSpotId: spotId)
    }

    func change(newSpotId spotId: OWSpotId) {
        resetPersistence()
        triggerNetworkNewUser(forSpotId: spotId)
    }
}

private extension OWAuthenticationManager {
    func resetPersistence() {
        let keychain = servicesProvider.keychain()

        // Remove persistence to the user availability and also "RAM" references
        let userAvailabilityMapper: OWUserAvailabilityMapper = [:]
        keychain.save(value: userAvailabilityMapper, forKey: OWKeychain.OWKey<OWUserAvailabilityMapper>.activeUser)
        self._activeUserAvailability.onNext(.notAvailable)
        self._userAuthenticationStatus.onNext(.notAutenticated)

        // Remove authorization if exist from before as this field associated to an active user
        if let credentials = keychain.get(key: OWKeychain.OWKey<OWNetworkSessionCredentials>.networkCredentials) {
            let newCredentials = OWNetworkSessionCredentials(guid: credentials.guid,
                                                          openwebToken: credentials.openwebToken,
                                                             authorization: nil)
            keychain.save(value: newCredentials, forKey: OWKeychain.OWKey<OWNetworkSessionCredentials>.networkCredentials)
            self._networkCredentials = newCredentials
        }
    }

    func loadPersistence(forSpotId spotId: OWSpotId) {
        let keychain = servicesProvider.keychain()

        if let userAvailabilityMapper = keychain.get(key: OWKeychain.OWKey<OWUserAvailabilityMapper>.activeUser),
            let userAvailability = userAvailabilityMapper[spotId] {
            self._activeUserAvailability.onNext(userAvailability)

            // Assuming user authentication status accordingly - renew SSO will take care of the actual `Authorization` header if needed to renew
            let status: OWInternalUserAuthenticationStatus
            switch userAvailability {
            case .user(let user):
                let userId = user.userId ?? ""
                status = user.registered ? .ssoLoggedIn(userId: userId) : .guest(userId: userId)
            case .notAvailable:
                status = .notAutenticated
            }

            self._userAuthenticationStatus.onNext(status)
        }
    }

    func loadGeneralPersistence() {
        let keychain = servicesProvider.keychain()

        // Loading from persistence if exist
        if let credentials = keychain.get(key: OWKeychain.OWKey<OWNetworkSessionCredentials>.networkCredentials) {
            self._networkCredentials = credentials
        }

        // Generating guid if needed
        if _networkCredentials.guid == nil {
            let randomGUID = randomGenerator.generateSuperiorUUID()
            let credentials = OWNetworkSessionCredentials(guid: randomGUID,
                                                             openwebToken: _networkCredentials.openwebToken,
                                                             authorization: _networkCredentials.authorization)
            update(credentials: credentials)
        }
    }

    func update(credentials: OWNetworkSessionCredentials) {
        self._networkCredentials = credentials
        let keychain = servicesProvider.keychain()
        keychain.save(value: credentials, forKey: OWKeychain.OWKey<OWNetworkSessionCredentials>.networkCredentials)
    }

    func update(userAvailability: OWUserAvailability) {
        self._activeUserAvailability.onNext(userAvailability)
        let keychain = servicesProvider.keychain()
        let spotId = OpenWeb.manager.spotId
        let userAvailabilityMapper: OWUserAvailabilityMapper = [spotId: userAvailability]
        keychain.save(value: userAvailabilityMapper, forKey: OWKeychain.OWKey<OWUserAvailabilityMapper>.activeUser)
    }
}

// Helper methods
private extension OWAuthenticationManager {
    func shouldShowAuthenticationUI(for action: OWUserAction) -> Observable<Bool> {
        return self.requiredAuthenticationLevel(for: action)
            .flatMap { [weak self] requiredlevel -> Observable<(OWAuthenticationLevel, OWAuthenticationLevel)> in
                guard let self = self else { return .empty() }
                return self.waitForAuthenticationLevel()
                    .take(1)
                    .map { ($0, requiredlevel) }
            }
            .map { tuple in
                let currentlevel = tuple.0
                let requiredlevel = tuple.1

                return currentlevel.level < requiredlevel.level
            }
    }

    func waitForAuthenticationLevel(aboveOrEqual requiredAuthenticationLevel: OWAuthenticationLevel) -> Observable<OWAuthenticationLevel> {
        return self.waitForAuthenticationLevel()
            .filter { level in
                return level.level >= requiredAuthenticationLevel.level
            }
            .take(1)
    }

    func waitForAuthenticationLevel() -> Observable<OWAuthenticationLevel> {
        return currentAuthenticationLevelAvailability
            .map { availability -> OWAuthenticationLevel? in
                guard case .level(let level) = availability else { return nil }
                return level
            }
            .unwrap()
    }

    func requiredAuthenticationLevel(for action: OWUserAction) -> Observable<OWAuthenticationLevel> {
        return manager.currentSpotId
            .take(1)
            .flatMap { [weak self] spotId -> Observable<SPSpotConfiguration> in
                guard let self = self else { return .empty()}
                return self.servicesProvider.spotConfigurationService().config(spotId: spotId)
                    .take(1)
            }
            .materialize()
            .map { [weak self] event -> OWAuthenticationLevel? in
                guard let self = self else { return nil }
                switch event {
                case .next(let config):
                    return self.requiredAuthenticationLevel(for: action, accordingToConfig: config)
                case .error:
                    return nil
                default:
                    return nil
                }
            }
            .unwrap()
    }

    func requiredAuthenticationLevel(for action: OWUserAction, accordingToConfig config: SPSpotConfiguration) -> OWAuthenticationLevel {
        let allowGuestsToLike = config.initialization?.policyAllowGuestsToLike ?? false
        let forceRegister = config.initialization?.policyForceRegister ?? true
        let levelAccordingToRegistration: OWAuthenticationLevel = forceRegister ? .loggedIn : .guest
        let requiredRegisterForReport = config.moderation?.requiredRegisterForReport ?? false

        switch action {
        case .commenting:
            return levelAccordingToRegistration
        case .replyingComment:
            return levelAccordingToRegistration
        case .mutingUser:
            return .loggedIn
        case .votingComment:
            return allowGuestsToLike ? .guest : .loggedIn
        case .reportingComment:
            return requiredRegisterForReport ? .loggedIn : .guest
        case .sharingComment:
            return .guest
        case .editingComment:
            return levelAccordingToRegistration
        case .deletingComment:
            return levelAccordingToRegistration
        case .viewingProfile:
            return .guest
        case .viewingSelfProfile:
            return levelAccordingToRegistration
        case .loginPrompt:
            return .loggedIn
        case .commenterAppeal:
            return .loggedIn
        }
    }

    func ensureSSORecoveryStatus(for originalUserId: String) {
        let statusObservable = userAuthenticationStatus
            .map { status -> OWInternalUserAuthenticationStatus? in
                if case .ssoLoggedIn = status {
                    return status
                } else {
                    return nil
                }
            }
            .unwrap()
            .take(1)
            .do(onNext: { [weak self] status in
                guard let self = self,
                        case .ssoLoggedIn(let userId) = status else { return }
                // Signal if the recovery was succesfull or not
                if userId == originalUserId {
                    self._userAuthenticationStatus.onNext(.ssoRecoveredSuccessfully(userId: originalUserId))
                } else {
                    let logger = self.servicesProvider.logger()
                    logger.log(level: .medium, "Successfully get new user after renew SSO, but it is not the same one that can conected before")
                    self._userAuthenticationStatus.onNext(.ssoFailedRecover(userId: originalUserId))
                }

                // Back to the previous status
                self._userAuthenticationStatus.onNext(status)
            })
            .voidify()

        let timeoutObservable = Observable.just(())
            .delay(.seconds(Metrics.maxSSORecoveryTime), scheduler: ConcurrentDispatchQueueScheduler(qos: .utility))
            .take(1)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                // Signal recovery failed due to timeout
                self._userAuthenticationStatus.onNext(.ssoFailedRecover(userId: originalUserId))
            })
            .flatMapLatest { [weak self] _ -> Observable<SPUser> in
                // Retrieve new guest user
                guard let self = self else { return .empty() }
                return self.retrieveNetworkNewUser()
            }
            .voidify()

        // Merge both observables and taking only the first one to return
        _ = Observable.merge(statusObservable, timeoutObservable)
            .take(1)
            .subscribe()
    }
}
