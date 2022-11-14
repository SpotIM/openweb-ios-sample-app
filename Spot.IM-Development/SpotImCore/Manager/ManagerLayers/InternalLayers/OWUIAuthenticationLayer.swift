//
//  OWUIAuthenticationLayer.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

protocol OWUIAuthenticationInternalProtocol {
    func triggerPublisherDisplayLoginFlow(navController: UINavigationController)
}

class OWUIAuthenticationLayer: OWUIAuthentication {
    var displayLoginFlow: OWLoginFlowCallback? {
        get {
            return self._displayLoginFlow
        }
        set(newValue) {
            self._displayLoginFlow = newValue
        }
    }
    
    fileprivate var _displayLoginFlow: OWLoginFlowCallback? = nil
    
    func triggerPublisherDisplayLoginFlow(navController: UINavigationController) {
        guard let callback = _displayLoginFlow else {
            let logger = OWSharedServicesProvider.shared.logger()
            logger.log(level: .error, "`displayLoginFlow` callback should be provided to `manager.ui.authentication` in order to display login flow.\nPlease provide this callback.")
            return
        }
        callback(navController)
    }
}
