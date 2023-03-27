//
//  OWUIAuthenticationLayer.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

protocol OWUIAuthenticationInternalProtocol {
    func triggerPublisherDisplayAuthenticationFlow(routeringMode: OWRouteringMode, completion: @escaping OWBasicCompletion)
}

class OWUIAuthenticationLayer: OWUIAuthentication, OWUIAuthenticationInternalProtocol {

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

    func triggerPublisherDisplayAuthenticationFlow(routeringMode: OWRouteringMode, completion: @escaping OWBasicCompletion) {
        guard let callback = _displayAuthenticationFlow else {
            let logger = servicesProvider.logger()
            logger.log(level: .error, "`displayAuthenticationFlow` callback should be provided to `manager.ui.authentication` in order to display login flow.\nPlease provide this callback.")
            return
        }
        DispatchQueue.main.async {
            callback(routeringMode, completion)
        }
    }
}
