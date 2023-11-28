//
//  OWAnalytics.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

public protocol OWAnalytics {
    var customBIData: OWCustomBIData { get set }
    func addBICallback(_ callback: @escaping OWBIAnalyticEventCallback)
}
