//
//  OWInitialSortStrategy+Analytics.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 31/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

extension OWInitialSortStrategy {
    var analyticsPayload: OWAnalyticEventPayload {
        switch (self) {
        case .use(let sortOption):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.initialSort: sortOption.rawValue])
        case .useServerConfig:
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.initialSort: "useServerConfig"])
        }
    }
}
