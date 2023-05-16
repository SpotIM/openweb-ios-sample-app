//
//  OWReportReason.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWReportReason: Codable {
    let reportType: OWReportReasonType
    let requiredAdditionalInfo: Bool
}

struct OWNetworkReportReason: Codable {
    let reportType: OWNetworkReportReasonType
    let requiredAdditionalInfo: Bool
}
