//
//  OWAnalytics.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public protocol OWAnalytics {
    // TODO: uncomment once `OWCustomBIData` and `OWAnalyticEventCallback` are ready
//    var customBIData: OWCustomBIData { get set }
//    func addBICallback(_ callback: OWAnalyticEventCallback)
}
#else
protocol OWAnalytics {
    // TODO: uncomment once `OWCustomBIData` and `OWAnalyticEventCallback` are ready
//    var customBIData: OWCustomBIData { get set }
//    func addBICallback(_ callback: OWAnalyticEventCallback)
}
#endif
