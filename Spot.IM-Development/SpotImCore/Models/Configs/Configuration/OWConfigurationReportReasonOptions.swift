//
//  OWConfigurationReportReasonOptions.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API

struct OWConfigurationReportReasonOptions: Codable {
    fileprivate let reasons: [OWNetworkReportReason]
    let reasonsList: [OWReportReason]

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.reasons = try values.decodeIfPresent([OWNetworkReportReason].self, forKey: .reasons)!

        self.reasonsList = self.reasons.filter({ $0.reportType != .new_reason_does_not_exist })
            .map {
                OWReportReason(reportType: $0.reportType.toReportReasonType, requiredAdditionalInfo: $0.requiredAdditionalInfo)
            }
    }
}

#endif
