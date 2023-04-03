//
//  OWConversationStyle+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 28/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API

extension OWConversationStyle {
    // swiftlint:disable function_parameter_count
    static func conversationStyle(fromIndex index: Int,
                                  communityGuidelinesStyleIndex: Int,
                                  communityQuestionsStyleIndex: Int,
                                  spacingIndex: Int,
                                  betweenComments: CGFloat,
                                  belowHeader: CGFloat,
                                  belowCommunityGuidelines: CGFloat,
                                  belowCommunityQuestions: CGFloat) -> OWConversationStyle {
        switch index {
        case 0: return .regular
        case 1: return .compact
        case 2: return .custom(communityGuidelinesStyle: OWCommunityGuidelinesStyle(index: communityGuidelinesStyleIndex),
                               communityQuestionsStyle: OWCommunityQuestionsStyle(index: communityQuestionsStyleIndex),
                               spacing: OWConversationSpacing(index: spacingIndex,
                                              betweenComments: betweenComments,
                                              belowHeader: belowHeader,
                                              belowCommunityGuidelines: belowCommunityGuidelines,
                                              belowCommunityQuestions: belowCommunityQuestions))
        default: return `default`
        }
    }
    // swiftlint:enable function_parameter_count

    static var defaultIndex: Int {
        return 0
    }

    static var `default`: OWConversationStyle {
        return .regular
    }

    static var customIndex: Int {
        return 2
    }
}

#endif
