//
//  OWManager+OWUI.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

extension OWManager: OWUI {
    var ui: OWUI { return uiLayer }
    var flows: OWUIFlows { return uiLayer as! OWUILayer }
    var views: OWUIViews { return uiLayer as! OWUILayer }
    var customizations: OWCustomizations { return (uiLayer as! OWUILayer).customizations }
    var authenticationUI: OWUIAuthentication { return (uiLayer as! OWUILayer).authenticationUI }
}
