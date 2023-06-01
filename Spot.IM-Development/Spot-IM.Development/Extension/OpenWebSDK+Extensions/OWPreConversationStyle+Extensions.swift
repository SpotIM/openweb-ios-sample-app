//
//  OWPreConversationStyle+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 28/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API

extension OWPreConversationStyle {
    static func preConversationStyle(fromIndex index: Int,
                                     numberOfComments: Int = OWPreConversationStyle.Metrics.defaultRegularNumberOfComments,
                                     communityGuidelinesStyleIndex: Int,
                                     communityQuestionsStyleIndex: Int) -> OWPreConversationStyle {
        switch index {
        case 0: return .regular
        case 1: return .compact
        case 2: return .ctaButtonOnly
        case 3: return .ctaWithSummary(communityGuidelinesStyle: OWCommunityGuidelinesStyle(index: communityGuidelinesStyleIndex),
                                       communityQuestionsStyle: OWCommunityQuestionsStyle(index: communityQuestionsStyleIndex))
        case 4: return .custom(numberOfComments: numberOfComments,
                               communityGuidelinesStyle: OWCommunityGuidelinesStyle(index: communityGuidelinesStyleIndex),
                               communityQuestionsStyle: OWCommunityQuestionsStyle(index: communityQuestionsStyleIndex))
        default: return `default`
        }
    }

    static var `default`: OWPreConversationStyle {
        return .regular
    }

    static var customIndex: Int {
        return 4
    }

    enum CodingKeys: String, CodingKey {
        case regular
        case compact
        case ctaButtonOnly
        case ctaWithSummary
        case custom
    }
}

#endif
