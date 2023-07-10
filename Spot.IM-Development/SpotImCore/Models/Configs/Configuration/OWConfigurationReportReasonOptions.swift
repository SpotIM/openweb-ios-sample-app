//
//  OWConfigurationReportReasonOptions.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWConfigurationReportReasonOptions: Codable {
    let reportReasons: [OWReportReason]

    enum CodingKeys: String, CodingKey {
        case reportReasons = "reasons"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        var reasons = [OWReportReason]()
        if let failableReasons = try values.decodeIfPresent([OWFailableWrapperDecodable<OWReportReason>].self, forKey: .reportReasons) {
            reasons = failableReasons.map { $0.wrappedValue }.unwrap()
        }

        reportReasons = reasons
    }
}
