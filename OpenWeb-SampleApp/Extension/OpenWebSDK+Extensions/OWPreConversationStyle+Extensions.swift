//
//  OWPreConversationStyle+Extensions.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 28/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK

extension OWPreConversationStyle {
    static func preConversationStyle(fromIndex index: Int,
                                     numberOfComments: Int = OWPreConversationStyle.Metrics.defaultRegularNumberOfComments,
                                     communityGuidelinesStyleIndex: Int,
                                     communityQuestionsStyleIndex: Int) -> OWPreConversationStyle {

        switch index {
        case OWPreConversationStyleIndexer.regular.index: return .regular
        case OWPreConversationStyleIndexer.compact.index: return .compact
        case OWPreConversationStyleIndexer.ctaButtonOnly.index: return .ctaButtonOnly
        case OWPreConversationStyleIndexer.ctaWithSummary.index: return .ctaWithSummary(communityGuidelinesStyle: OWCommunityGuidelinesStyle(index: communityGuidelinesStyleIndex),
                                                                                        communityQuestionsStyle: OWCommunityQuestionStyle(index: communityQuestionsStyleIndex))
        case OWPreConversationStyleIndexer.custom.index: return .custom(numberOfComments: numberOfComments,
                                       communityGuidelinesStyle: OWCommunityGuidelinesStyle(index: communityGuidelinesStyleIndex),
                                       communityQuestionsStyle: OWCommunityQuestionStyle(index: communityQuestionsStyleIndex))
        default: return `default`
        }
    }

    static var defaultIndex: Int {
        return OWPreConversationStyleIndexer.regular.index
    }

    static var `default`: OWPreConversationStyle {
        return .regular
    }

    enum CodingKeys: String, CodingKey {
        case regular
        case compact
        case ctaButtonOnly
        case ctaWithSummary
        case custom
    }
}
