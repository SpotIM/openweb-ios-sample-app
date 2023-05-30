//
//  OWAnalyticEvent.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 12/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

struct OWAnalyticEvent: OWUpdaterProtocol {
    let type: OWAnalyticEventType
    let timestamp: TimeInterval
}
