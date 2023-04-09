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
        guard case let .regular(numberOfComments) = self else { return self }
        if (numberOfComments > Metrics.maxNumberOfComments) || (numberOfComments < Metrics.minNumberOfComments) {
            return .regular()
        } else {
            return self
        }
    }

    var numberOfComments: Int {
        switch self {
        case .regular(let numOfComments):
            return numOfComments
        case .compact:
            return InternalMetrics.numberOfCommentsForCompactStyle
        default:
            return 0
        }
    }

    var collapsableTextLineLimit: Int {
        switch self {
        case .regular:
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
        case .regular, .ctaWithSummary:
            return .regular
        case .ctaButtonOnly:
            return .none
        }
    }

    var communityGuidelinesStyle: OWCommunityGuidelinesStyle {
        switch self {
        case .regular, .ctaWithSummary:
            return .regular // TODO - support guidelines regular/compact modes configuration
        case .compact, .ctaButtonOnly:
            return .none
        }
    }

    var communityQuestionStyle: OWCommunityQuestionsStyle {
        switch self {
        case .regular, .ctaWithSummary:
            return .regular
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
        case (.regular(let lhsNumOfComments), .regular(let rhsNumOfComments)):
            return lhsNumOfComments == rhsNumOfComments
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
        case (.regular(let lhsNumOfComments), .regular(let rhsNumOfComments)):
            return lhsNumOfComments == rhsNumOfComments
        default:
            return false
        }
    }
}
#endif
