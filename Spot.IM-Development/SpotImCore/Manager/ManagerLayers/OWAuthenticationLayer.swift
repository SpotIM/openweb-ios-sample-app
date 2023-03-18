//
//  OWAuthenticationLayer.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

protocol OWAuthenticationInternalProtocol {
    func triggerRenewSSO(userId: String, completion: OWBasicCompletion)
}

class OWAuthenticationLayer: OWAuthentication {
    func sso(_ flowType: OWSSOFlowType) {
        // TODO: Complete
    }

    func userStatus(completion: @escaping OWUserAuthenticationStatusCompletion) {
        // TODO: Complete
    }

    func logout(completion: @escaping OWDefaultCompletion) {
        // TODO: Complete
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

    func triggerRenewSSO(userId: String, completion: OWBasicCompletion) {
        guard let callback = _renewSSOCallback else {
            let logger = OWSharedServicesProvider.shared.logger()
            logger.log(level: .error, "`renewSSO` callback should be provided to `manager.authentication` in order to trigger renew SSO flow.\nPlease provide this callback.")
            return
        }
        callback(userId, completion)
    }
}
