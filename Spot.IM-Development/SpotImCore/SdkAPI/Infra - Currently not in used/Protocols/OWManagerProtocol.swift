//
//  OWManagerProtocol.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

// Will be a public protocol which expose the different layers of the manager
protocol OWManagerProtocol {
    var spotId: OWSpotId { get set }
    var postId: OWPostId? { get set }
    var ui: OWUI { get }
    var analytics: OWAnalytics { get }
}
