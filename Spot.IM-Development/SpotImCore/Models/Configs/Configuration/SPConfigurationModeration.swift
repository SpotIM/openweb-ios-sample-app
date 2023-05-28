//
//  SPConfigurationModeration.swift
//  SpotImCore
//
//  Created by Alon Haiut on 22/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct SPConfigurationModeration: Decodable {
    let requiredRegisterForReport: Bool?

    enum CodingKeys: String, CodingKey {
        case requiredRegisterForReport = "block_report_by_registered"
    }
}
