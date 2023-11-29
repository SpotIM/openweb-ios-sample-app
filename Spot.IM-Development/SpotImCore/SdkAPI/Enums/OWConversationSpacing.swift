//
//  OWSpacing.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

public enum OWConversationSpacing: Codable {
    public struct Metrics {
        public static let defaultSpaceBetweenComments: CGFloat = 28.0
        public static let defaultSpaceCommunityGuidelines: CGFloat = 12.0
        public static let defaultSpaceCommunityQuestions: CGFloat = 12.0
        public static let maxSpace: CGFloat = 40.0
        public static let minSpace: CGFloat = 5.0
    }

    case regular
    case compact
    case custom(betweenComments: CGFloat, communityGuidelines: CGFloat, communityQuestions: CGFloat)
}
