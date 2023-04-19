//
//  OWReportReasonType.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API

// All new reasons need to be added both in OWNetworkReportReasonType and OWReportReasonType
enum OWNetworkReportReasonType: String, Codable {
    case identity_attack
    case hate_speech
    case inappropriate_language
    case spam
    case false_information
    case sexual_activity
    case profile
    case child_abuse
    case terrorism
    case copyright_infringement
    case other
    case new_reason_does_not_exist

    init(from decoder: Decoder) throws {
        // 1
        let container = try decoder.singleValueContainer()
        // 2
        let rawString = try container.decode(String.self)

        // 3
        if let reportReasonType = OWNetworkReportReasonType(rawValue: rawString) {
            self = reportReasonType
        } else {
            // 4
            self = .new_reason_does_not_exist
        }
    }

    var toReportReasonType: OWReportReasonType {
        if let reportType = OWReportReasonType(rawValue: self.rawValue) {
            return reportType
        }
        fatalError("All new reasons need to be added both in OWNetworkReportReasonType and OWReportReasonType")
    }
}

enum OWReportReasonType: String, Codable {
    case identity_attack
    case hate_speech
    case inappropriate_language
    case spam
    case false_information
    case sexual_activity
    case profile
    case child_abuse
    case terrorism
    case copyright_infringement
    case other
}

extension OWReportReasonType {
    var localizedTitle: String {
        return LocalizationManager.localizedString(key: "\(self.rawValue)_title")
    }

    var localizedSubtitle: String {
        return LocalizationManager.localizedString(key: "\(self.rawValue)_subtitle")
    }
}

#endif
