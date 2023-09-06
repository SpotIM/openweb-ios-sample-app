//
//  OWConversationSpacing+Extensions.swift
//  SpotImCore
//
//  Created by Revital Pisman on 06/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

extension OWConversationSpacing {

    var betweenComments: CGFloat {
        switch self {
        case .regular:
            return Metrics.defaultSpaceBetweenComments
        case .compact:
            return Metrics.defaultSpaceBetweenComments
        case .custom(betweenComments: let betweenComments, communityGuidelines: _, communityQuestions: _):
            return min(max(betweenComments, Metrics.minSpace), Metrics.maxSpace)
        }
    }

    var communityGuidelines: CGFloat {
        switch self {
        case .regular:
            return Metrics.defaultSpaceCommunityGuidelines
        case .compact:
            return Metrics.defaultSpaceCommunityGuidelines
        case .custom(betweenComments: _, communityGuidelines: let communityGuidelinesSpacing, communityQuestions: _):
            return min(max(communityGuidelinesSpacing, Metrics.minSpace), Metrics.maxSpace)
        }
    }

    var communityQuestions: CGFloat {
        switch self {
        case .regular:
            return Metrics.defaultSpaceCommunityQuestions
        case .compact:
            return Metrics.defaultSpaceCommunityQuestions
        case .custom(betweenComments: _, communityGuidelines: _, communityQuestions: let communityQuestionsSpacing):
            return min(max(communityQuestionsSpacing, Metrics.minSpace), Metrics.maxSpace)
        }
    }
}

#if NEW_API
extension OWConversationSpacing: Equatable {
    public static func == (lhs: OWConversationSpacing, rhs: OWConversationSpacing) -> Bool {
        switch (lhs, rhs) {
        case (.regular, .regular):
            return true
        case (.compact, .compact):
            return true
        case (.custom(let lhsBetweenComments, let lhsCommunityGuidelinesSpacing, let lhsCommunityQuestionsSpacing),
              .custom(let rhsBetweenComments, let rhsCommunityGuidelinesSpacing, let rhsCommunityQuestionsSpacing)):
            return lhsBetweenComments == rhsBetweenComments &&
            lhsCommunityGuidelinesSpacing == rhsCommunityGuidelinesSpacing &&
            lhsCommunityQuestionsSpacing == rhsCommunityQuestionsSpacing
        default:
            return false
        }
    }
}
#else
extension OWConversationSpacing: Equatable {
    static func == (lhs: OWConversationSpacing, rhs: OWConversationSpacing) -> Bool {
        switch (lhs, rhs) {
        case (.regular, .regular):
            return true
        case (.compact, .compact):
            return true
        case (.custom(let lhsBetweenComments, let lhsCommunityGuidelinesSpacing, let lhsCommunityQuestionsSpacing),
              .custom(let rhsBetweenComments, let rhsCommunityGuidelinesSpacing, let rhsCommunityQuestionsSpacing)):
            return lhsBetweenComments == rhsBetweenComments &&
            lhsCommunityGuidelinesSpacing == rhsCommunityGuidelinesSpacing &&
            lhsCommunityQuestionsSpacing == rhsCommunityQuestionsSpacing
        default:
            return false
        }
    }
}
#endif
