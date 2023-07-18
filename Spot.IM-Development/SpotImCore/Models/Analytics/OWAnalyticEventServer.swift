//
//  OWAnalyticEventServer.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 12/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWAnalyticEventServer: Encodable {
    let eventName: String
    let eventGroup: String
    let eventTimestamp: Double
    let productName: OWProductSource = .conversation
    let componentName: String
    let payload: OWAnalyticEventPayload
    let generalData: OWAnalyticEventServerGeneralData
    let abTests: OWAnalyticEventServerAbTest = OWAnalyticEventServerAbTest()
}
