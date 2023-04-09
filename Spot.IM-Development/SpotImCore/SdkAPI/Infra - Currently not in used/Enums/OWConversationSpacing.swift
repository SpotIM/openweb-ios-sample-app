//
//  OWSpacing.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

#if NEW_API
public enum OWConversationSpacing: Codable {
    public struct Metrics {
        public static let defaultSpaceBetweenComments: CGFloat = 6.0 // Will be set later by designer
        public static let defaultSpaceBelowHeader: CGFloat = 8.0 // Will be set later by designer
        public static let defaultSpaceBelowCommunityGuidelines: CGFloat = 8.0 // Will be set later by designer
        public static let defaultSpaceBelowCommunityQuestions: CGFloat = 8.0 // Will be set later by designer
        public static let maxSpace: CGFloat = 20.0
        public static let minSpace: CGFloat = 0.0
    }

    case regular
    case compact
    case custom(betweenComments: CGFloat, belowHeader: CGFloat, belowCommunityGuidelines: CGFloat, belowCommunityQuestions: CGFloat)
}
#else
enum OWConversationSpacing: Codable {
    struct Metrics {
        static let defaultSpaceBetweenComments: CGFloat = 6.0 // Will be set later by designer
        static let defaultSpaceBelowHeader: CGFloat = 8.0 // Will be set later by designer
        static let defaultSpaceBelowCommunityGuidelines: CGFloat = 8.0 // Will be set later by designer
        static let defaultSpaceBelowCommunityQuestions: CGFloat = 8.0 // Will be set later by designer
        static let maxSpace: CGFloat = 20.0
        static let minSpace: CGFloat = 0.0
    }

    case regular
    case compact
    case custom(betweenComments: CGFloat, belowHeader: CGFloat, belowCommunityGuidelines: CGFloat, belowCommunityQuestions: CGFloat)
}
#endif

