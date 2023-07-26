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
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.style: "regular"])
        case .compact:
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.style: "compact"])
        case .ctaButtonOnly:
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.style: "ctaButtonOnly"])
        case .ctaWithSummary(let communityGuidelinesStyle, let communityQuestionsStyle):
            return OWAnalyticEventPayload(payloadDictionary: [
                OWAnalyticEventPayloadKeys.style: "ctaWithSummary",
                OWAnalyticEventPayloadKeys.communityGuidelinesStyle: communityGuidelinesStyle,
                OWAnalyticEventPayloadKeys.communityQuestionsStyle: communityQuestionsStyle
            ])
        case .custom(let numberOfComments, let communityGuidelinesStyle, let communityQuestionsStyle):
            return OWAnalyticEventPayload(payloadDictionary: [
                OWAnalyticEventPayloadKeys.style: "custom",
                OWAnalyticEventPayloadKeys.numberOfComments: numberOfComments,
                OWAnalyticEventPayloadKeys.communityGuidelinesStyle: communityGuidelinesStyle,
                OWAnalyticEventPayloadKeys.communityQuestionsStyle: communityQuestionsStyle
            ])
        }
    }
}
