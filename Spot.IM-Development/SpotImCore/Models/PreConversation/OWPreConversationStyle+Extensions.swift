//
//  OWPreConversationStyle+Extensions.swift
//  SpotImCore
//
//  Created by Alon Haiut on 31/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

extension OWPreConversationStyle {
    struct InternalMetrics {
        static let numberOfCommentsForCompactStyle: Int = 1
        static let collapsableTextLineLimit: Int = 4
        static let collapsableTextLineLimitCompactMode: Int = 2
    }

    func validate() -> OWPreConversationStyle {
        guard case let .custom(numberOfComments, communityGuidelines, communityQuestion) = self else { return self }
        if (numberOfComments > Metrics.maxNumberOfComments) || (numberOfComments < Metrics.minNumberOfComments) {
            return .custom(numberOfComments: Metrics.defaultRegularNumberOfComments,
                           communityGuidelinesStyle: communityGuidelines,
                           communityQuestionsStyle: communityQuestion)
        } else {
            return self
        }
    }

    var styleIdentifier: String {
        switch self {
        case .regular:
            return "regular"
        case .compact:
            return "compact"
        case .ctaButtonOnly:
            return "button_only"
        case .ctaWithSummary:
            return "summary"
        case .custom:
            return "custom"
        }
    }

    var numberOfComments: Int {
        switch self {
        case .regular:
            return Metrics.defaultRegularNumberOfComments
        case .compact:
            return InternalMetrics.numberOfCommentsForCompactStyle
        case .custom(let numberOfComments, _, _):
            return numberOfComments
        default:
            return 0
        }
    }

    var collapsableTextLineLimit: Int {
        switch self {
        case .regular, .custom:
            return InternalMetrics.collapsableTextLineLimit
        case .compact:
            return InternalMetrics.collapsableTextLineLimitCompactMode
        default:
            return InternalMetrics.collapsableTextLineLimit
        }
    }

    var preConversationSummaryStyle: OWPreConversationSummaryStyle {
        switch self {
        case .compact:
            return .compact
        case .regular, .ctaWithSummary, .custom:
            return .regular
        case .ctaButtonOnly:
            return .none
        }
    }

    var communityGuidelinesStyle: OWCommunityGuidelinesStyle {
        switch self {
        case .regular:
            return .regular
        case .custom(_, let communityGuidelinesStyle, _), .ctaWithSummary(let communityGuidelinesStyle, _):
            return communityGuidelinesStyle
        case .compact, .ctaButtonOnly:
            return .none
        }
    }

    var communityQuestionStyle: OWCommunityQuestionsStyle {
        switch self {
        case .regular:
            return .regular
        case .custom(_, _, let communityQuestionStyle), .ctaWithSummary(_, let communityQuestionStyle):
            return communityQuestionStyle
        case .compact, .ctaButtonOnly:
            return .none
        }
    }

}

#if NEW_API
extension OWPreConversationStyle: Equatable {
    public static func == (lhs: OWPreConversationStyle, rhs: OWPreConversationStyle) -> Bool {
        switch (lhs, rhs) {
        case (.compact, .compact):
            return true
        case (.ctaButtonOnly, .ctaButtonOnly):
            return true
        case (.ctaWithSummary, .ctaWithSummary):
            return true
        case (.regular, .regular):
            return true
        case (.custom(let lhsNumberOfComments, let lhsCommunityGuidelinesStyle, let lhsCommunityQuestionStyle),
              .custom(let rhsNumberOfComments, let rhsCommunityGuidelinesStyle, let rhsCommunityQuestionStyle)):
            return lhsNumberOfComments == rhsNumberOfComments &&
            lhsCommunityGuidelinesStyle == rhsCommunityGuidelinesStyle &&
            lhsCommunityQuestionStyle == rhsCommunityQuestionStyle
        default:
            return false
        }
    }
}
#else
extension OWPreConversationStyle: Equatable {
    static func == (lhs: OWPreConversationStyle, rhs: OWPreConversationStyle) -> Bool {
        switch (lhs, rhs) {
        case (.compact, .compact):
            return true
        case (.ctaButtonOnly, .ctaButtonOnly):
            return true
        case (.ctaWithSummary, .ctaWithSummary):
            return true
        case (.regular, .regular):
            return true
        case (.custom(let lhsNumberOfComments, let lhsCommunityGuidelinesStyle, let lhsCommunityQuestionStyle),
              .custom(let rhsNumberOfComments, let rhsCommunityGuidelinesStyle, let rhsCommunityQuestionStyle)):
            return lhsNumberOfComments == rhsNumberOfComments &&
            lhsCommunityGuidelinesStyle == rhsCommunityGuidelinesStyle &&
            lhsCommunityQuestionStyle == rhsCommunityQuestionStyle
        default:
            return false
        }
    }
}
#endif
