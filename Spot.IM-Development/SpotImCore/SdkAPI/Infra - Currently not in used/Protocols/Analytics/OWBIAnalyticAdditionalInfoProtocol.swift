//
//  OWBIAnalyticAdditionalInfoProtocol.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 14/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public protocol OWBIAnalyticAdditionalInfoProtocol {
    var customBIData: OWCustomBIData { get }
}
#else
protocol OWBIAnalyticAdditionalInfoProtocol {
    var customBIData: OWCustomBIData { get }
}
#endif
