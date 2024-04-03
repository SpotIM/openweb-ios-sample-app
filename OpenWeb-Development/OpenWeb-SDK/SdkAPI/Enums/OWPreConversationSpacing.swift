//
//  OWPreConversationSpacing.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 03/04/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import UIKit

public enum OWPreConversationSpacing: Codable {
    public struct Metrics {
        public static let defaultSpaceBetweenComments: CGFloat = 28.0
        public static let defaultSpaceCommunityGuidelines: CGFloat = 12.0 // TODO: check
        public static let defaultSpaceCommunityQuestions: CGFloat = 12.0 // TODO: check
    }

    case regular
}
