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

    func ifNeededTriggerAuthenticationUI(for action: OWUserAction) -> Observable<Bool>
    func waitForAuthentication(for action: OWUserAction, waitForBlockingCompletions: Bool) -> Observable<Void>
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
    }

    fileprivate let _userAuthenticationStatus = BehaviorSubject<OWInternalUserAuthenticationStatus>(value: .notAutenticated)
    var userAuthenticationStatus: Observable<OWInternalUserAuthenticationStatus> {
        return _userAuthenticationStatus
            .share(replay: 1)
    }

    var currentAuthenticationLevelAvailability: Observable<OWAuthenticationLevelAvailability> {
        return userAuthenticationStatus
            .map { $0.authenticationLevelAvailability }
    }

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
}
