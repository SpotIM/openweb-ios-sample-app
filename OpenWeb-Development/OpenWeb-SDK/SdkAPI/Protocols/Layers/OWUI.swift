//
//  OWUI.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

public protocol OWUI {
    var flows: OWUIFlows { get }
    var views: OWUIViews { get }
    var customizations: OWCustomizations { get }
    var authenticationUI: OWUIAuthentication { get }
}
