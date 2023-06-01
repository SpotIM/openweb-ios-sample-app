//
//  OWPreConversationStyle.swift
//  SpotImCore
//
//  Created by Alon Haiut on 31/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWPreConversationStyle: Codable {
    public struct Metrics {
        public static let defaultCommunityGuidelinesStyle: OWCommunityGuidelinesStyle = .regular
        public static let defaultCommunityQuestionsStyle: OWCommunityQuestionsStyle = .regular
        public static let defaultRegularNumberOfComments: Int = 2
        public static let minNumberOfComments: Int = 1
        public static let maxNumberOfComments: Int = 8
    }

    case regular
    case compact
    case ctaButtonOnly // Called "Button only mode" - no title, before the refactor
    case ctaWithSummary(communityGuidelinesStyle: OWCommunityGuidelinesStyle = Metrics.defaultCommunityGuidelinesStyle,
                        communityQuestionsStyle: OWCommunityQuestionsStyle = Metrics.defaultCommunityQuestionsStyle) // Called "Button only mode" - title, before the refactor
    case custom(numberOfComments: Int = Metrics.defaultRegularNumberOfComments,
                communityGuidelinesStyle: OWCommunityGuidelinesStyle = Metrics.defaultCommunityGuidelinesStyle,
                communityQuestionsStyle: OWCommunityQuestionsStyle = Metrics.defaultCommunityQuestionsStyle)
}

#else
enum OWPreConversationStyle: Codable {
    struct Metrics {
        static let defaultCommunityGuidelinesStyle: OWCommunityGuidelinesStyle = .regular
        static let defaultCommunityQuestionsStyle: OWCommunityQuestionsStyle = .regular
        static let defaultRegularNumberOfComments: Int = 2
        static let minNumberOfComments: Int = 1
        static let maxNumberOfComments: Int = 8
    }

    case regular
    case compact
    case ctaButtonOnly // Called "Button only mode" - no title, before the refactor
    case ctaWithSummary(communityGuidelinesStyle: OWCommunityGuidelinesStyle,
                        communityQuestionsStyle: OWCommunityQuestionsStyle) // Called "Button only mode" - title, before the refactor
    case custom(numberOfComments: Int = Metrics.defaultRegularNumberOfComments,
                communityGuidelinesStyle: OWCommunityGuidelinesStyle = Metrics.defaultCommunityGuidelinesStyle,
                communityQuestionsStyle: OWCommunityQuestionsStyle = Metrics.defaultCommunityQuestionsStyle)
}
#endif
