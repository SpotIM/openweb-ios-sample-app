//
//  OWBIAnalyticAdditionalInfo.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 14/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

public struct OWBIAnalyticAdditionalInfo: OWBIAnalyticAdditionalInfoProtocol {
    public var customBIData: OWCustomBIData

    public init(customBIData: OWCustomBIData = [:]) {
        self.customBIData = customBIData
    }
}
