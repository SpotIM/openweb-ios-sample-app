//
//  OWAppealReason.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 21/11/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWAppealReason: Codable {
    let type: OWAppealReasonType
    let requiredAdditionalInfo: Bool

    enum CodingKeys: String, CodingKey {
        case type = "appealType"
        case requiredAdditionalInfo
    }
}
