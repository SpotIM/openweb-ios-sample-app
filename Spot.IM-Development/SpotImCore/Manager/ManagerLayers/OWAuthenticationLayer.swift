//
//  OWAuthenticationLayer.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

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

    var shouldDisplayLoginPrompt: Bool {
        get {
            return _shouldDisplayLoginPrompt
        }
        set(newValue) {
            _shouldDisplayLoginPrompt = newValue
        }
    }

    fileprivate var _shouldDisplayLoginPrompt: Bool = false
}
