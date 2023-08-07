//
//  OWBatchAnalyticsResponse.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 25/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWBatchAnalyticsResponse: Codable {
    var failures: [OWBatchError]?
}

struct OWBatchError: Codable {
    var index: Int
    var error: String
}
