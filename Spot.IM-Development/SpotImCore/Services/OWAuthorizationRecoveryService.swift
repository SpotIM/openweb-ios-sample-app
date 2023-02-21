//
//  OWAuthorizationRecoveryService.swift
//  SpotImCore
//
//  Created by Alon Haiut on 21/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWAuthorizationRecoveryServicing {
    func recoverFromAuthorizationError(userId: String) -> Observable<Void>
}
class OWAuthorizationRecoveryService: OWAuthorizationRecoveryServicing {
    fileprivate unowned let servicesProvider: OWSharedServicesProviding
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

    init (servicesProvider: OWSharedServicesProviding) {
        self.servicesProvider = servicesProvider
    }

    func recoverFromAuthorizationError(userId: String) -> Observable<Void> {
        if let didJustRecovered = didJustRecoveredCache[userId], didJustRecovered {
            // Return cache configuration
            return .just(())
        } else {
            return isCurrentlyRecovering
                .take(1)
                .flatMap { [weak self] isRecovering -> Observable<Void> in
                    guard let self = self else { return .empty() }
                    if !isRecovering {
                        self.startRecovering(userId: userId)
                    }

                    // This way if other calls to this functions are being done before the network request finish, we won't send new requests
                    return self.recoverJustFinished
                        .take(1)
                }
        }
    }
}

fileprivate extension OWAuthorizationRecoveryService {
    func startRecovering(userId: String) {
        let disposeBag = DisposeBag()
        self.disposeBag = disposeBag

        // Due to bad architecture it is not possible to dependency injection the authProvider in the class initializer
        _ = Observable.just(())
            .flatMap { [weak self] _ -> Observable<Bool> in
                self?.isCurrentlyRecovering.onNext(true)

                // Due to bad architecture it is not possible to dependency injection those classes
                // Get new user session and reset the old one
                // Also check if we should renew SSO after the process
                let isUserRegistered = SPUserSessionHolder.isRegister()
                let isSSO = SPConfigsDataSource.appConfig?.initialization?.ssoEnabled ?? false
                let shouldRenewSSO = isUserRegistered && isSSO
                SPUserSessionHolder.resetUserSession()
                return .just(shouldRenewSSO)
            }
            .flatMap { shouldRenewSSO -> Observable<SPUser> in
                return SpotIm.authProvider
                    .getUser()
                    .take(1) // No need to dispose
                    .do(onNext: { [weak self] _ in
                        guard let self = self else { return  }
                        self.isCurrentlyRecovering.onNext(false)
                        self._recoverJustFinished.onNext(())
                        self.didJustRecoveredCache[userId] = true

                        if shouldRenewSSO {
                            // Will renew SSO with publishers API if a user was logged in before
                            self.servicesProvider.logger().log(level: .verbose, "Renew SSO triggered after network 403 error code")
                            SpotIm.authProvider.renewSSOPublish.onNext(userId)
                        }
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
