//
//  OWUI.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public protocol OWUI {
    var flows: OWUIFlows { get }
    var views: OWUIViews { get }
    var helpers: OWHelpers { get }
    var authenticationUI: OWUIAuthentication { get }
}
#else
protocol OWUI {
    var flows: OWUIFlows { get }
    var views: OWUIViews { get }
    var helpers: OWHelpers { get }
    var authenticationUI: OWUIAuthentication { get }
}
#endif
