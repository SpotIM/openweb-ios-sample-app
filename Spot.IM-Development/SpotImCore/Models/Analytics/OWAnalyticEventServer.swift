//
//  OWAnalyticEventServer.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 12/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWAnalyticEventServer: Encodable {
    var eventName: String
    var eventGroup: String
    var eventTimestamp: Double
    var productName: String = "conversation"
    var componentName: String
    var payload: OWAnalyticEventPayload
    var generalData: OWAnalyticEventServerGeneralData
    var abTests: OWAnalyticEventServerAbTest = OWAnalyticEventServerAbTest()
}
