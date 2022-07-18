//
//  OWManager+OWAnalytics.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

extension OWManager: OWAnalytics {
    var analytics: OWAnalytics { return analyticsLayer }
}
