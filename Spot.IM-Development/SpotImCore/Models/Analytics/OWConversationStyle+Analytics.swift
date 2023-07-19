//
//  OWConversationStyle+Analytics.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 19/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

extension OWConversationStyle {
    var analyticsPayload: OWAnalyticEventPayload {
        switch self {
        case .regular:
            return OWAnalyticEventPayload(payloadDictionary: ["style": "regular"])
        case .compact:
            return OWAnalyticEventPayload(payloadDictionary: ["style": "compact"])
        case .custom(let communityGuidelinesStyle, let communityQuestionsStyle, let spacing):
            return OWAnalyticEventPayload(payloadDictionary: [
                "style": "custom",
                "communityGuidelinesStyle": communityGuidelinesStyle,
                "communityQuestionsStyle": communityQuestionsStyle,
                "spacing": spacing
            ])
        }
    }
}
