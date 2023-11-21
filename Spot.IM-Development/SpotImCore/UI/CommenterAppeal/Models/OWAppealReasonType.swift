//
//  OWAppealReasonType.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 21/11/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWAppealReasonType: String, Codable {
    case disagreeGuidelines = "disagree-guidelines"
    case dontUnderstandGuidelines = "dont-understand-guidelines"
    case commentFollowsGuidelines = "comment-follows-guidelines"
    case misunderstanding
    case other
}

extension OWAppealReasonType {
    private var localizationKey: String {
        return rawValue
            .split(separator: "_")
            .map { String($0).capitalized }
            .joined()
    }

    var localizedTitle: String {
        return OWLocalizationManager.shared.localizedString(key: "\(self.localizationKey)AppealTitle")
    }
}
