//
//  OWUIAuthenticationLayer.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

class OWUIAuthenticationLayer: OWUIAuthentication {
    var displayLoginFlow: OWLoginFlowCallback? { return self._displayLoginFlow }
    
    fileprivate var _displayLoginFlow: OWLoginFlowCallback? = nil
}
