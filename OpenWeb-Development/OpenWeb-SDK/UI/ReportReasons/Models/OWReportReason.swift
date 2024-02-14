//
//  OWReportReason.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

struct OWReportReason: Codable {
    let type: OWReportReasonType
    let requiredAdditionalInfo: Bool

    enum CodingKeys: String, CodingKey {
        case type = "reportType"
        case requiredAdditionalInfo
    }
}
