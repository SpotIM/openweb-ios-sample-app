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
            return .regular
        case .custom(communityGuidelinesStyle: _, communityQuestionsStyle: let communityQuestionsStyle, spacing: _):
            return communityQuestionsStyle
        }
    }

}
