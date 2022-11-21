//
//  OWManager+Layers.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

extension OWManager {
    var ui: OWUI {
        return uiLayer
    }
    
    var analytics: OWAnalytics {
        return analyticsLayer
    }
    
    var monetization: OWMonetization {
        return monetizationLayer
    }
    
    var authentication: OWAuthentication {
        return authenticationLayer
    }
    
    var helpers: OWHelpers {
        return helpersLayer
    }
}
