//
//  OWAuthenticationLayer.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWAuthenticationInternalProtocol {
    func triggerRenewSSO(userId: String, completion: @escaping OWBasicCompletion)
}

class OWAuthenticationLayer: OWAuthentication, OWAuthenticationInternalProtocol {

    fileprivate let servicesProvider: OWSharedServicesProviding

    init (servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }

    func sso(_ flowType: OWSSOFlowType) {
        switch flowType {
        case .start(let completion):
            self.handleSSOStart(completion: completion)
        case .complete(let codeB, let completion):
            self.handleSSOComplete(codeB: codeB, completion: completion)
        case .usingProvider(let provider, let token, let completion):
            self.handleSSOUsingProvider(privder: provider, token: token, completion: completion)
        }
    }

    func userStatus(completion: @escaping OWUserAuthenticationStatusCompletion) {
        guard validateSpotIdExist(completion: completion) else { return }

        let authenticationManager = servicesProvider.authenticationManager()
        _ = authenticationManager
            .userAuthenticationStatus
            .map { $0.toOWUserAuthenticationStatus() }
            .unwrap()
            .take(1)
            .subscribe(onNext: { status in
                completion(.success(status))
            }, onError: { err in
                let error: OWError = err as? OWError ?? OWError.userStatus
                completion(.failure(error))
            })
    }

    func logout(completion: @escaping OWDefaultCompletion) {
        guard validateSpotIdExist(completion: completion) else { return }

        let authenticationManager = servicesProvider.authenticationManager()
        _ = authenticationManager
            .logout()
            .take(1)
            .subscribe(onNext: { _ in
                completion(.success(()))
            }, onError: { err in
                let error: OWError = err as? OWError ?? OWError.logout
                completion(.failure(error))
            })
    }

    var renewSSO: OWRenewSSOCallback? {
        get {
            return _renewSSOCallback
        }
        set(newValue) {
            _renewSSOCallback = newValue
        }
    }

    var shouldDisplayLoginPrompt: Bool {
        get {
            return _shouldDisplayLoginPrompt
        }
        set(newValue) {
            _shouldDisplayLoginPrompt = newValue
        }
    }

    fileprivate var _shouldDisplayLoginPrompt: Bool = false
    fileprivate var _renewSSOCallback: OWRenewSSOCallback? = nil

    func triggerRenewSSO(userId: String, completion: @escaping OWBasicCompletion) {
        guard let callback = _renewSSOCallback else {
            let logger = servicesProvider.logger()
            logger.log(level: .error, "`renewSSO` callback should be provided to `manager.authentication` in order to trigger renew SSO flow.\nPlease provide this callback.")
            return
        }
        callback(userId, completion)
    }
}

fileprivate extension OWAuthenticationLayer {
    func handleSSOStart(completion: @escaping OWSSOStartHandler) {
        guard validateSpotIdExist(completion: completion) else { return }

        let authenticationManager = servicesProvider.authenticationManager()
        _ = authenticationManager
            .startSSO()
            .take(1)
            .subscribe(onNext: { ssoStartModel in
                completion(.success(ssoStartModel))
            }, onError: { err in
                let error: OWError = err as? OWError ?? OWError.ssoStart
                completion(.failure(error))
            })
    }

    func handleSSOComplete(codeB: String, completion: @escaping OWSSOCompletionHandler) {
        guard validateSpotIdExist(completion: completion) else { return }

        let authenticationManager = servicesProvider.authenticationManager()
        _ = authenticationManager
            .completeSSO(codeB: codeB)
            .take(1)
            .subscribe(onNext: { ssoCompleteModel in
                completion(.success(ssoCompleteModel))
            }, onError: { err in
                let error: OWError = err as? OWError ?? OWError.ssoComplete
                completion(.failure(error))
            })
    }

    func handleSSOUsingProvider(privder: OWSSOProvider, token: String, completion: @escaping OWProviderSSOHandler) {
        guard validateSpotIdExist(completion: completion) else { return }

    }

    func validateSpotIdExist<T: Any>(completion: @escaping (Result<T, OWError>) -> Void) -> Bool {
        let spotId = OpenWeb.manager.spotId
        guard !spotId.isEmpty else {
            completion(.failure(.missingSpotId))
            return false
        }

        return true
    }
}
