//
//  OWReportReasonType.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWReportReasonType: String, Codable {
    case identityAttack = "identity_attack"
    case hateSpeech = "hate_speech"
    case inappropriateLanguage = "inappropriate_language"
    case spam
    case falseInformation = "false_information"
    case sexualActivity = "sexual_activity"
    case profile
    case childAbuse = "child_abuse"
    case terrorism
    case copyrightInfringement = "copyright_infringement"
    case other
}

extension OWReportReasonType {
    private var localizationKey: String {
        return rawValue
            .split(separator: "_")
            .map { String($0).capitalized }
            .joined()
    }

    var localizedTitle: String {
        return OWLocalizationManager.shared.localizedString(key: "\(self.localizationKey)Title")
    }

    var localizedSubtitle: String {
        return OWLocalizationManager.shared.localizedString(key: "\(self.localizationKey)Subtitle")
    }
}
