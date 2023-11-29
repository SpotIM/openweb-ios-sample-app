//
//  OWConversationSpacing+Extensions.swift
//  SpotImCore
//
//  Created by Revital Pisman on 06/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

extension OWConversationSpacing {

    func validate(_ spacing: CGFloat? = nil) -> OWConversationSpacing {
        guard case let .custom(betweenCommentsSpacing, communityGuidelinesSpacing, communityQuestionsSpacing) = self else { return self }
        let betweenComments = min(max(betweenCommentsSpacing, Metrics.minSpace), Metrics.maxSpace)
        let communityGuidelines = min(max(communityGuidelinesSpacing, Metrics.minSpace), Metrics.maxSpace)
        let communityQuestions = min(max(communityQuestionsSpacing, Metrics.minSpace), Metrics.maxSpace)

        return .custom(betweenComments: betweenComments,
                       communityGuidelines: communityGuidelines,
                       communityQuestions: communityQuestions)
    }

    var betweenComments: CGFloat {
        switch self {
        case .regular:
            return Metrics.defaultSpaceBetweenComments
        case .compact:
            return Metrics.defaultSpaceBetweenComments
        case .custom(betweenComments: let betweenComments, communityGuidelines: _, communityQuestions: _):
            return betweenComments
        }
    }

    var communityGuidelines: CGFloat {
        switch self {
        case .regular:
            return Metrics.defaultSpaceCommunityGuidelines
        case .compact:
            return Metrics.defaultSpaceCommunityGuidelines
        case .custom(betweenComments: _, communityGuidelines: let communityGuidelinesSpacing, communityQuestions: _):
            return communityGuidelinesSpacing
        }
    }

    var communityQuestions: CGFloat {
        switch self {
        case .regular:
            return Metrics.defaultSpaceCommunityQuestions
        case .compact:
            return Metrics.defaultSpaceCommunityQuestions
        case .custom(betweenComments: _, communityGuidelines: _, communityQuestions: let communityQuestionsSpacing):
            return communityQuestionsSpacing
        }
    }
}

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
