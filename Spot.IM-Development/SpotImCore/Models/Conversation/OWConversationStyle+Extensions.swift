//
//  OWConversationStyle+Extensions.swift
//  SpotImCore
//
//  Created by Revital Pisman on 29/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

extension OWConversationStyle {

    var communityGuidelinesStyle: OWCommunityGuidelinesStyle {
        switch self {
        case .regular:
            return .regular
        case .compact:
            return .compact
        case .custom(communityGuidelinesStyle: let communityGuidelinesStyle, communityQuestionsStyle: _, spacing: _):
            return communityGuidelinesStyle
        }
    }

    var communityQuestionStyle: OWCommunityQuestionsStyle {
        switch self {
        case .regular:
            return .regular
        case .compact:
            return .compact
        case .custom(communityGuidelinesStyle: _, communityQuestionsStyle: let communityQuestionsStyle, spacing: _):
            return communityQuestionsStyle
        }
    }

}

#if NEW_API
extension OWConversationStyle: Equatable {
    public static func == (lhs: OWConversationStyle, rhs: OWConversationStyle) -> Bool {
        switch (lhs, rhs) {
        case (.compact, .compact):
            return true
        case (.regular, .regular):
            return true
        case (.custom(let lhsCommunityGuidelinesStyle, let lhsCommunityQuestionStyle, _),
              .custom(let rhsCommunityGuidelinesStyle, let rhsCommunityQuestionStyle, _)):
            return lhsCommunityGuidelinesStyle == rhsCommunityGuidelinesStyle && lhsCommunityQuestionStyle == rhsCommunityQuestionStyle
        default:
            return false
        }
    }
}
#else
extension OWConversationStyle: Equatable {
    static func == (lhs: OWConversationStyle, rhs: OWConversationStyle) -> Bool {
        switch (lhs, rhs) {
        case (.compact, .compact):
            return true
            return true
        case (.regular, .regular):
            return true
        case (.custom(let lhsCommunityGuidelinesStyle, let lhsCommunityQuestionStyle, _),
              .custom(let rhsCommunityGuidelinesStyle, let rhsCommunityQuestionStyle, _)):
            return lhsCommunityGuidelinesStyle == rhsCommunityGuidelinesStyle && lhsCommunityQuestionStyle == rhsCommunityQuestionStyle
        default:
            return false
        }
    }
}
#endif
