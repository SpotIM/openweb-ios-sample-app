//
//  OWManagerProtocol.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDKAdapter

public protocol OWManagerProtocol {
    var spotId: OWSpotId { get set }
    var ui: OWUI { get }
    var analytics: OWAnalytics { get }
    var monetization: OWMonetization { get }
    var authentication: OWAuthentication { get }
    var helpers: OWHelpers { get }
    #if BETA
    var environment: OWNetworkEnvironmentType { get set }
    #endif
}
