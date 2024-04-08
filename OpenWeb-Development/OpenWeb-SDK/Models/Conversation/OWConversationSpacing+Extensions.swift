//
//  OWConversationSpacing+Extensions.swift
//  OpenWebSDK
//
//  Created by Revital Pisman on 06/09/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
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

    var betweenComments: OWVerticalSpacing {
        switch self {
        case .regular:
            return OWVerticalSpacing(Metrics.defaultSpaceBetweenComments)
        case .compact:
            return OWVerticalSpacing(Metrics.defaultSpaceBetweenComments)
        case .custom(betweenComments: let betweenComments, communityGuidelines: _, communityQuestions: _):
            return OWVerticalSpacing(betweenComments)
        }
    }

    var communityGuidelines: OWVerticalSpacing {
        switch self {
        case .regular:
            return OWVerticalSpacing(Metrics.defaultSpaceCommunityGuidelines)
        case .compact:
            return OWVerticalSpacing(Metrics.defaultSpaceCommunityGuidelines)
        case .custom(betweenComments: _, communityGuidelines: let communityGuidelinesSpacing, communityQuestions: _):
            return OWVerticalSpacing(communityGuidelinesSpacing)
        }
    }

    var communityQuestions: OWVerticalSpacing {
        switch self {
        case .regular:
            return OWVerticalSpacing(Metrics.defaultSpaceCommunityQuestions)
        case .compact:
            return OWVerticalSpacing(Metrics.defaultSpaceCommunityQuestions)
        case .custom(betweenComments: _, communityGuidelines: _, communityQuestions: let communityQuestionsSpacing):
            return OWVerticalSpacing(communityQuestionsSpacing)
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
