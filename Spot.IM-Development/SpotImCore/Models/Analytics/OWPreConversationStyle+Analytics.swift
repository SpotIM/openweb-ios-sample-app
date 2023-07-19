//
//  OWPreConversationStyle+Analytics.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 19/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

extension OWPreConversationStyle {
    var analyticsPayload: OWAnalyticEventPayload {
        switch self {
        case .regular:
            return OWAnalyticEventPayload(payloadDictionary: ["style": "regular"])
        case .compact:
            return OWAnalyticEventPayload(payloadDictionary: ["style": "compact"])
        case .ctaButtonOnly:
            return OWAnalyticEventPayload(payloadDictionary: ["style": "ctaButtonOnly"])
        case .ctaWithSummary(let communityGuidelinesStyle, let communityQuestionsStyle):
            return OWAnalyticEventPayload(payloadDictionary: [
                "style": "ctaWithSummary",
                "communityGuidelinesStyle": communityGuidelinesStyle,
                "communityQuestionsStyle": communityQuestionsStyle
            ])
        case .custom(let numberOfComments, let communityGuidelinesStyle, let communityQuestionsStyle):
            return OWAnalyticEventPayload(payloadDictionary: [
                "style": "custom",
                "numberOfComments": numberOfComments,
                "communityGuidelinesStyle": communityGuidelinesStyle,
                "communityQuestionsStyle": communityQuestionsStyle
            ])
        }
    }
}
