//
//  OWAuthenticationLayer.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 13/11/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWAuthenticationInternalProtocol {
    func triggerRenewSSO(userId: String, completion: @escaping OWBasicCompletion)
}

class OWAuthenticationLayer: OWAuthentication, OWAuthenticationInternalProtocol {

    private let servicesProvider: OWSharedServicesProviding

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
            self.handleSSOUsingProvider(provider: provider, token: token, completion: completion)
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
            .subscribe(onNext: { [weak self] _ in
                // Need to update the reported comments service after logout succeeded
                self?.servicesProvider.reportedCommentsService().cleanCache()
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

    private var _shouldDisplayLoginPrompt: Bool = false
    private var _renewSSOCallback: OWRenewSSOCallback?

    func triggerRenewSSO(userId: String, completion: @escaping OWBasicCompletion) {
        guard let callback = _renewSSOCallback else {
            let logger = servicesProvider.logger()
            logger.log(level: .error, "`renewSSO` callback should be provided to `manager.authentication` in order to trigger renew SSO flow.\nPlease provide this callback.")
            return
        }
        DispatchQueue.main.async {
            callback(userId, completion)
        }
    }
}

private extension OWAuthenticationLayer {
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

    func handleSSOUsingProvider(provider: OWSSOProvider, token: String, completion: @escaping OWProviderSSOHandler) {
        guard validateSpotIdExist(completion: completion) else { return }

        let authenticationManager = servicesProvider.authenticationManager()
        _ = authenticationManager
            .ssoAuthenticate(withProvider: provider, token: token)
            .take(1)
            .subscribe(onNext: { ssoProviderModel in
                completion(.success(ssoProviderModel))
            }, onError: { err in
                let error: OWError = err as? OWError ?? OWError.ssoProvider
                completion(.failure(error))
            })
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
