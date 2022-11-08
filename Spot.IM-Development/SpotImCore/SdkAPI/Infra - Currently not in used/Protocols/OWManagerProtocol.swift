//
//  OWManagerProtocol.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public protocol OWManagerProtocol {
    var spotId: OWSpotId { get set }
    var ui: OWUI { get }
    var analytics: OWAnalytics { get }
    var monetization: OWMonetization { get }
    var authentication: OWUIAuthentication { get }
    var customizations: OWCustomizations { get }
}
#else
protocol OWManagerProtocol {
    var spotId: OWSpotId { get set }
    var ui: OWUI { get }
    var analytics: OWAnalytics { get }
    var monetization: OWMonetization { get }
    var authentication: OWUIAuthentication { get }
    var customizations: OWCustomizations { get }
}
#endif
