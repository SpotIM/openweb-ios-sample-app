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
    func activateRenewSSO(userId: String)
    func logout() -> Observable<Void>
}

extension OWAuthenticationManagerProtocol {
    func waitForAuthentication(for action: OWUserAction) -> Observable<Void> {
        return self.waitForAuthentication(for: action, waitForBlockingCompletions: true)
    }
}

class OWAuthenticationManager: OWAuthenticationManagerProtocol {

    fileprivate unowned let manager: OWManagerProtocol & OWManagerInternalProtocol
    fileprivate unowned let servicesProvider: OWSharedServicesProviding

    init (manager: OWManagerProtocol & OWManagerInternalProtocol = OWManager.manager,
          servicesProvider: OWSharedServicesProviding) {
        self.manager = manager
        self.servicesProvider = servicesProvider

        loadPersistence()
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
                      let routeringCompatible = self.manager.ui.authenticationUI as? OWRouteringCompatible,
                      let navController = routeringCompatible.routering.navigationController,
                      let authenticationUILayer = self.manager.ui.authenticationUI as? OWUIAuthenticationInternalProtocol else { return }
                let blockerService = self.servicesProvider.blockerServicing()
                let blockerAction = OWDefaultBlockerAction(blockerType: .authentication)
                blockerService.add(blocker: blockerAction)
                authenticationUILayer.triggerPublisherDisplayLoginFlow(navController: navController, completion: blockerAction.completion)
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
                }
            })
    }

    func activateRenewSSO(userId: String) {
        guard let authenticationLayer = self.manager.authentication as? OWAuthenticationInternalProtocol else { return }
        let blockerService = self.servicesProvider.blockerServicing()
        let blockerAction = OWDefaultBlockerAction(blockerType: .renewAuthentication)
        blockerService.add(blocker: blockerAction)
        authenticationLayer.triggerRenewSSO(userId: userId, completion: blockerAction.completion)
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
}

// Persistence related methods
fileprivate extension OWAuthenticationManager {
    func loadPersistence() {
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

        if let userAvailability = keychain.get(key: OWKeychain.OWKey<OWUserAvailability>.activeUser) {
            self._activeUserAvailability.onNext(userAvailability)
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
        keychain.save(value: userAvailability, forKey: OWKeychain.OWKey<OWUserAvailability>.activeUser)
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

        switch action {
        case .commenting:
            return levelAccordingToRegistration
        case .mutingUser:
            return levelAccordingToRegistration
        case .votingComment:
            return allowGuestsToLike ? .guest : .loggedIn
        case .reportingComment:
            return .loggedIn
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
}
