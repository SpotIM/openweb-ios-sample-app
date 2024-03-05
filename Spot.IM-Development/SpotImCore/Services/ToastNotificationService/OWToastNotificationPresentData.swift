//
//  OWToastNotificationPresentData.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 22/02/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import Foundation

struct OWToastNotificationPresentData: Codable, Equatable {
    var uuid = UUID().uuidString
    let data: OWToastRequiredData
    var durationInSec: Double = 5
}
