//
//  OWBIAnalyticAdditionalInfo.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 14/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWBIAnalyticAdditionalInfo: OWBIAnalyticAdditionalInfoProtocol {
    public var customBIData: OWCustomBIData

    public init(customBIData: OWCustomBIData = [:]) {
        self.customBIData = customBIData
    }
}
#else
struct OWBIAnalyticAdditionalInfo: OWBIAnalyticAdditionalInfoProtocol {
    let customBIData: OWCustomBIData
}
#endif
