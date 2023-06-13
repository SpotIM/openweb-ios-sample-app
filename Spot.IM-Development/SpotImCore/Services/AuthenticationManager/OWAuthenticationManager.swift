//
//  OWAuthenticationManager.swift
//  SpotImCore
//
//  Created by Alon Haiut on 12/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
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
    func waitForAuthentication(for action: OWUserAction, waitForBlockingCompletions: Bool) -> Observable<Void>

    func enterAuthenticationRecoveryState()
    func finishAuthenticationRecovery(with authenticationRecovery: OWAuthenticationRecoveryResult)
    func logout() -> Observable<Void>
    func startSSO() -> Observable<OWSSOStartModel>
    func completeSSO(codeB: String) -> Observable<OWSSOCompletionModel>

    // Those methods exposed since we are testing multiple SpotIds inside our SampleApp - therefore we must considered the "current" spotId
    func prepare(forSpotId spotId: OWSpotId)
    func change(newSpotId spotId: OWSpotId)
}

extension OWAuthenticationManagerProtocol {
    func waitForAuthentication(for action: OWUserAction) -> Observable<Void> {
        return self.waitForAuthentication(for: action, waitForBlockingCompletions: true)
    }
}

class OWAuthenticationManager: OWAuthenticationManagerProtocol {

    fileprivate typealias OWUserAvailabilityMapper = [OWSpotId: OWUserAvailability]
    fileprivate unowned let manager: OWManagerProtocol & OWManagerInternalProtocol
    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate let scheduler: SchedulerType

    fileprivate struct Metrics {
        static let maxSSORecoveryTime: Int = 30 // In seconds
        static let maxAttemptsToObtainNewUser: Int = 3
        static let delayToObtainUser: Int = 1000 // In ms
    }

    init (manager: OWManagerProtocol & OWManagerInternalProtocol = OWManager.manager,
          servicesProvider: OWSharedServicesProviding,
          scheduler: SchedulerType = SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: "OpenWebSDKAuthenticationManagerQueue")) {
        self.manager = manager
        self.servicesProvider = servicesProvider
        self.scheduler = scheduler

        loadGeneralPersistence()
    }

    fileprivate var _networkCredentials = OWNetworkSessionCredentials.none
    var networkCredentials: OWNetworkSessionCredentials {
        return _networkCredentials
    }

    fileprivate let _activeUserAvailability = BehaviorSubject<OWUserAvailability>(value: .notAvailable)
    var activeUserAvailability: Observable<OWUserAvailability> {
        return _activeUserAvailability
            .distinctUntilChanged()
            .share(replay: 1)
    }

    fileprivate let _userAuthenticationStatus = BehaviorSubject<OWInternalUserAuthenticationStatus>(value: .notAutenticated)
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
                      let routeringCompatible = self.manager.ui as? OWRouteringCompatible,
                      let authenticationUILayer = self.manager.ui.authenticationUI as? OWUIAuthenticationInternalProtocol else { return }
                let blockerService = self.servicesProvider.blockerServicing()
                let blockerAction = OWDefaultBlockerAction(blockerType: .authentication)
                blockerService.add(blocker: blockerAction)

                /*
                 TODO: We need a better way to distinguish whether we are in a flow mode or standalone component.
                 Will be done once we will actually work with standalone components
                */

                let routeringMode: OWRouteringMode
                if let navController = routeringCompatible.routering.navigationController {
                    routeringMode = .flow(navigationController: navController)
                } else {
                   routeringMode = .none
                }
                authenticationUILayer.triggerPublisherDisplayAuthenticationFlow(routeringMode: routeringMode, completion: blockerAction.completion)
            })
    }

    func waitForAuthentication(for action: OWUserAction, waitForBlockingCompletions: Bool = true) -> Observable<Void> {
        return self.requiredAuthenticationLevel(for: action)
            .flatMap { [weak self] requiredlevel -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.waitForAuthenticationLevel(aboveOrEqual: requiredlevel)
                    .take(1)
                    .voidify()
            }
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                if waitForBlockingCompletions {
                    return self.servicesProvider.blockerServicing().waitForNonBlocker()
                } else {
                    return .just(())
                }
            }
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

    fileprivate func obtainNetworkUserIfNeeded(forSpotId spotId: OWSpotId) {
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

    fileprivate func triggerNetworkNewUser(forSpotId spotId: OWSpotId) {
        _ = self.retrieveNetworkNewUser()
            .subscribe()
    }

    fileprivate func retrieveNetworkNewUser() -> Observable<SPUser> {
        let configurationService = servicesProvider.spotConfigurationService()

        return configurationService.config(spotId: OpenWeb.manager.spotId)
            .observe(on: scheduler)
            .take(1) // Here we are simply waiting for the config first / ensuring such exist for the specific spotId
            .flatMap { [weak self] _ -> Observable<SPUser> in
                guard let self = self else { return .empty() }
                let authentication = self.servicesProvider.netwokAPI().authentication
                return authentication
                    .user()
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
        let networkAuthentication = servicesProvider.netwokAPI().authentication

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
                self.update(userAvailability: .notAvailable)
                self._userAuthenticationStatus.onNext(.notAutenticated)
            })
            .voidify()
    }

    func startSSO() -> Observable<OWSSOStartModel> {
        return _activeUserAvailability
            .take(1)
            .flatMap { [weak self] userAvailablity -> Observable<Void> in
                guard let self = self else { return .empty() }
                // 1. Logout current user if needed
                if case .user(_) = userAvailablity {
                    return self.logout()
                } else {
                    return .just(())
                }
            }
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                // 2. Login (usually will provide a guest user))
                let networkAuthentication = self.servicesProvider.netwokAPI().authentication
                return networkAuthentication
                    .login()
                    .response
                    .do(onNext: { [weak self] user in
                        guard let self = self else { return }
                        self.update(userAvailability: .user(user))
                        self._userAuthenticationStatus.onNext(.guest(userId: user.userId ?? ""))
                    })
                    .voidify()
            }
            .flatMap { [weak self] _ -> Observable<OWSSOStartResponse> in
                guard let self = self else { return .empty() }
                // 2. Start SSO
                guard let authorization = self._networkCredentials.authorization else { return .error(OWError.ssoStart)}
                let networkAuthentication = self.servicesProvider.netwokAPI().authentication
                return networkAuthentication
                    .ssoStart(secret: authorization)
                    .response
            }
            .map { $0.toSSOStartModel() }
    }

    func completeSSO(codeB: String) -> Observable<OWSSOCompletionModel> {
        return userAuthenticationStatus
            .take(1)
            .flatMap { authenticationStatus -> Observable<Void> in
                // 1. Make sure not already logged in
                if case .guest(_) = authenticationStatus {
                    return .just(())
                } else if authenticationStatus == .notAutenticated {
                    return .just(())
                }

                return .error(OWError.alreadyLoggedIn)
            }
            .flatMap { [weak self] _ -> Observable<OWSSOCompletionResponse> in
                guard let self = self else { return .empty() }
                // 2. Proceed with SSO complete
                let networkAuthentication = self.servicesProvider.netwokAPI().authentication
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

fileprivate extension OWAuthenticationManager {
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
            let randomGUID = self.generateGUID()
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
fileprivate extension OWAuthenticationManager {
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
            .map { [weak self] config -> OWAuthenticationLevel? in
                guard let self = self else { return nil }
                return self.requiredAuthenticationLevel(for: action, accordingToConfig: config)
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
        case .mutingUser:
            return levelAccordingToRegistration
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
        }
    }

    func generateGUID() -> String {
        // Returning a simple uuid string, however when looking on hundreds of milion guid, this might be not "randomised" enough.
        // We should think of adding some "seed" by the date interval for example
        return UUID().uuidString
    }

    func ensureSSORecoveryStatus(for originalUserId: String) {
        let statusObservable = userAuthenticationStatus
            .map { status -> OWInternalUserAuthenticationStatus? in
                if case .ssoLoggedIn(_) = status {
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
                    self._userAuthenticationStatus.onNext(.ssoFailedRecover(userId: originalUserId))
                }

                // Back to the previous status
                self._userAuthenticationStatus.onNext(status)
            })
            .voidify()

        let timeoutObservable = Observable.just(())
            .delay(.seconds(Metrics.maxSSORecoveryTime), scheduler: ConcurrentDispatchQueueScheduler(qos: .utility))
            .flatMap { [weak self] _ -> Observable<OWInternalUserAuthenticationStatus> in
                guard let self = self else { return .empty() }
                return self.userAuthenticationStatus
            }
            .take(1)
            .do(onNext: { [weak self] status in
                guard let self = self else { return }
                // Signal recovery failed due to timeout
                self._userAuthenticationStatus.onNext(.ssoFailedRecover(userId: originalUserId))

                // Back to the previous status
                self._userAuthenticationStatus.onNext(status)
            })
            .voidify()

        // Merge both observables and taking only the first one to return
        _ = Observable.merge(statusObservable, timeoutObservable)
            .take(1)
            .subscribe()
    }
}
