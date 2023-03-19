//
//  OWAuthorizationRecoveryService.swift
//  SpotImCore
//
//  Created by Alon Haiut on 16/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWAuthorizationRecoveryServicing {
    func recoverAuthorization() -> Observable<Void>
}
class OWAuthorizationRecoveryService: OWAuthorizationRecoveryServicing {
    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate let scheduler: SchedulerType
    // Cache if we just recovered for a minute (key is the userId)
    fileprivate let didJustRecoveredCache = OWCacheService<String, Bool>(expirationStrategy: .time(lifetime: 60))
    fileprivate var disposeBag: DisposeBag? = DisposeBag()
    fileprivate let isCurrentlyRecovering = BehaviorSubject<Bool>(value: false)
    fileprivate let _recoverJustFinished = BehaviorSubject<Void?>(value: nil)
    fileprivate var recoverJustFinished: Observable<Void> {
        return _recoverJustFinished
            .unwrap()
            .share(replay: 0) // New subscribers will get only elements which emits after their subscription
    }

    init (servicesProvider: OWSharedServicesProviding,
          scheduler: SchedulerType = SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: "OpenWebSDKAuthorizationRecoveryServiceQueue")) {
        self.servicesProvider = servicesProvider
        self.scheduler = scheduler
    }

    func recoverAuthorization() -> Observable<Void> {

        let authenticationManager = servicesProvider.authenticationManager()
        return authenticationManager.activeUserAvailability
            .take(1)
            .observe(on: scheduler)
            .flatMap { [weak self] userAvailability -> Observable<Void> in
                guard let self = self else { return .empty() }

                if case OWUserAvailability.user(let user) = userAvailability,
                   let userId = user.userId,
                   let didJustRecovered = self.didJustRecoveredCache[userId],
                   didJustRecovered {
                    // Skip recovery, we just recovered recently
                    return .just(())
                } else {
                    return self.isCurrentlyRecovering
                       .take(1)
                       .flatMap { [weak self] isRecovering -> Observable<Void> in
                           guard let self = self else { return .empty() }
                           if !isRecovering {
                               self.isCurrentlyRecovering.onNext(true)
                               self.startRecovering(userAvailability: userAvailability)
                           }

                           // This way if other calls to this functions are being done before the network request finish, we won't send new requests
                           return self.recoverJustFinished
                               .take(1)
                       }
                }
            }
    }
}

fileprivate extension OWAuthorizationRecoveryService {
    func startRecovering(userAvailability: OWUserAvailability) {
        let disposeBag = DisposeBag()
        self.disposeBag = disposeBag
        let configurationService = servicesProvider.spotConfigurationService()

        _ = configurationService.config(spotId: OpenWeb.manager.spotId)
            .observe(on: scheduler)
            .take(1)
            .flatMap { [weak self] config -> Observable<Bool> in
                guard let self = self else { return .empty() }

                // Get new user session and reset the old one
                // Also check if we should renew SSO after the process
                var shouldRenewSSO = false
                if case OWUserAvailability.user(let user) = userAvailability,
                   user.registered,
                   let isSSO = config.initialization?.ssoEnabled, isSSO {
                    shouldRenewSSO = true
                }

                // Reset authorization
                let authenticationManager = self.servicesProvider.authenticationManager()
                authenticationManager.enterAuthenticationRecoveryState()
                return .just(shouldRenewSSO)
            }
            .flatMap { [weak self] shouldRenewSSO -> Observable<SPUser> in
                guard let self = self else { return .empty() }
                let authentication = self.servicesProvider.netwokAPI().authentication
                return authentication
                    .user()
                    .response
                    .observe(on: self.scheduler)
                    .take(1) // No need to dispose
                    .do(onNext: { [weak self] newUser in
                        guard let self = self else { return }
                        self.isCurrentlyRecovering.onNext(false)
                        self._recoverJustFinished.onNext(())

                        let authenticationRecoveryResult: OWAuthenticationRecoveryResult
                        if case OWUserAvailability.user(let user) = userAvailability,
                           let userId = user.userId {
                            self.didJustRecoveredCache[userId] = true
                            if shouldRenewSSO {
                                // Will renew SSO with publishers API if a user was logged in before
                                self.servicesProvider.logger().log(level: .verbose, "Renew SSO triggered after network 403 error code")
                                authenticationRecoveryResult = .AuthenticationRenewed(user: user)
                            } else {
                                authenticationRecoveryResult = .newAuthentication(user: newUser)
                            }
                        } else {
                            authenticationRecoveryResult = .newAuthentication(user: newUser)
                        }

                        let authenticationManager = self.servicesProvider.authenticationManager()
                        authenticationManager.finishAuthenticationRecovery(with: authenticationRecoveryResult)
                    }, onError: {[weak self] error in
                        guard let self = self else { return  }
                        self.isCurrentlyRecovering.onNext(false)
                        self._recoverJustFinished.onError(error)
                    })
                }
                .subscribe()
                .disposed(by: disposeBag)
    }
}
