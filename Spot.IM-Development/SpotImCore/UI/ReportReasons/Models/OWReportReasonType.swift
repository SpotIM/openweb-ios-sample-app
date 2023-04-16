//
//  OWReportReasonType.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWReportReasonType: String, Codable {
    case identity_attack = "identityAttack"
    case hate_speech = "hateSpeech"
    case inappropriate_language = "inappropriateLanguage"
    case spam = "spam"
    case false_information = "falseInformation"
    case sexual_activity = "sexualActivity"
    case profile = "profile"
    case child_abuse = "childAbuse"
    case terrorism = "terrorism"
    case copyright_infringement = "copyrightInfringement"
    case other = "other"
}
