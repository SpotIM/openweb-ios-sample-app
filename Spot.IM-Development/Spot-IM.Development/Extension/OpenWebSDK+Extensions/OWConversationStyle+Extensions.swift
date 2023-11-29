//
//  OWConversationStyle+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 28/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

extension OWConversationStyle {
    // swiftlint:disable function_parameter_count
    static func conversationStyle(fromIndex index: Int,
                                  communityGuidelinesStyleIndex: Int,
                                  communityQuestionsStyleIndex: Int,
                                  spacingIndex: Int,
                                  betweenComments: CGFloat,
                                  belowCommunityGuidelines: CGFloat,
                                  belowCommunityQuestions: CGFloat) -> OWConversationStyle {
        // swiftlint:enable function_parameter_count

        switch index {
        case OWConversationStyleIndexer.regular.index: return .regular
        case OWConversationStyleIndexer.compact.index: return .compact
        case OWConversationStyleIndexer.custom.index: return .custom(communityGuidelinesStyle: OWCommunityGuidelinesStyle(index: communityGuidelinesStyleIndex),
                                                                communityQuestionsStyle: OWCommunityQuestionStyle(index: communityQuestionsStyleIndex),
                                                                spacing: OWConversationSpacing(index: spacingIndex,
                                                                                               betweenComments: betweenComments,
                                                                                               communityGuidelines: belowCommunityGuidelines,
                                                                                               communityQuestions: belowCommunityQuestions))
        default: return `default`
        }
    }

    static var defaultIndex: Int {
        return OWConversationStyleIndexer.regular.index
    }

    static var `default`: OWConversationStyle {
        return .regular
    }
}
