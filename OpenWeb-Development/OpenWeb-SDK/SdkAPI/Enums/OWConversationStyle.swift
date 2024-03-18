//
//  OWConversationStyle.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 31/01/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

public enum OWConversationStyle: Codable {
    public struct Metrics {
        public static let defaultCommunityGuidelinesStyle: OWCommunityGuidelinesStyle = .regular
        public static let defaultCommunityQuestionsStyle: OWCommunityQuestionStyle = .regular
        public static let defaultSpacing: OWConversationSpacing = .custom(betweenComments: OWConversationSpacing.Metrics.defaultSpaceBetweenComments,
                                                                          communityGuidelines: OWConversationSpacing.Metrics.defaultSpaceCommunityGuidelines,
                                                                          communityQuestions: OWConversationSpacing.Metrics.defaultSpaceCommunityQuestions)
    }

    case regular
    case compact
    case custom(communityGuidelinesStyle: OWCommunityGuidelinesStyle = Metrics.defaultCommunityGuidelinesStyle,
                communityQuestionsStyle: OWCommunityQuestionStyle = Metrics.defaultCommunityQuestionsStyle,
                spacing: OWConversationSpacing = Metrics.defaultSpacing)
}
