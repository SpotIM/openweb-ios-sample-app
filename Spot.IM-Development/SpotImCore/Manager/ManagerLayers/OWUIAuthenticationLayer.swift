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
    var displayLoginFlow: OWLoginFlowCallback? { return self._displayLoginFlow }
    
    fileprivate var _displayLoginFlow: OWLoginFlowCallback? = nil
    
    func triggerPublisherDisplayLoginFlow(navController: UINavigationController) {
        guard let callback = _displayLoginFlow else { return }
        callback(navController)
    }
}
