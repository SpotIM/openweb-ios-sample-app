//
//  OWUIAuthenticationLayer.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

protocol OWUIAuthenticationInternalProtocol {
    func triggerPublisherDisplayLoginFlow(navController: UINavigationController, completion: OWBasicCompletion)
}

class OWUIAuthenticationLayer: OWUIAuthentication {

    fileprivate let servicesProvider: OWSharedServicesProviding

    init (servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }

    var displayAuthenticationFlow: OWAuthenticationFlowCallback? {
        get {
            return self._displayAuthenticationFlow
        }
        set(newValue) {
            self._displayAuthenticationFlow = newValue
        }
    }

    fileprivate var _displayAuthenticationFlow: OWAuthenticationFlowCallback? = nil

    func triggerPublisherDisplayAuthenticationFlow(navController: UINavigationController, completion: OWBasicCompletion) {
        guard let callback = _displayAuthenticationFlow else {
            let logger = servicesProvider.logger()
            logger.log(level: .error, "`displayAuthenticationFlow` callback should be provided to `manager.ui.authentication` in order to display login flow.\nPlease provide this callback.")
            return
        }
        callback(navController, completion)
    }
}
