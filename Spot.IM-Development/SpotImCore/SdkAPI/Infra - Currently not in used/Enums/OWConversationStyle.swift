//
//  OWConversationStyle.swift
//  SpotImCore
//
//  Created by Alon Haiut on 31/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWConversationStyle: Codable {
    public struct Metrics {
        public static let defaultCommunityGuidelinesStyle: OWCommunityGuidelinesStyle = .regular
        public static let defaultCommunityQuestionsStyle: OWCommunityQuestionStyle = .regular
        public static let defaultSpacing: OWConversationSpacing = .custom(betweenComments: OWConversationSpacing.Metrics.defaultSpaceBetweenComments,
                                                                          belowHeader: OWConversationSpacing.Metrics.defaultSpaceBelowHeader,
                                                                          belowCommunityGuidelines: OWConversationSpacing.Metrics.defaultSpaceBelowCommunityGuidelines,
                                                                          belowCommunityQuestions: OWConversationSpacing.Metrics.defaultSpaceBelowCommunityQuestions)
    }

    case regular
    case compact
    case custom(communityGuidelinesStyle: OWCommunityGuidelinesStyle = Metrics.defaultCommunityGuidelinesStyle,
                communityQuestionsStyle: OWCommunityQuestionStyle = Metrics.defaultCommunityQuestionsStyle,
                spacing: OWConversationSpacing = Metrics.defaultSpacing)
}

#else
enum OWConversationStyle: Codable {
    public struct Metrics {
        public static let defaultCommunityGuidelinesStyle: OWCommunityGuidelinesStyle = .regular
        public static let defaultCommunityQuestionsStyle: OWCommunityQuestionStyle = .regular
    }

    case regular
    case compact
    case custom(communityGuidelinesStyle: OWCommunityGuidelinesStyle = Metrics.defaultCommunityGuidelinesStyle,
                communityQuestionsStyle: OWCommunityQuestionStyle = Metrics.defaultCommunityQuestionsStyle,
                spacing: OWConversationSpacing)
}
#endif
