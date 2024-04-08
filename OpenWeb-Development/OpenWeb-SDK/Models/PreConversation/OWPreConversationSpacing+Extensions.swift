//
//  OWPreConversationSpacing+Extensions.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 03/04/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

extension OWPreConversationSpacing {
    var betweenComments: OWVerticalSpacing {
        switch self {
        case .regular:
            return OWVerticalSpacing(Metrics.defaultSpaceBetweenComments)
        }
    }

    var commentSpacingWithThread: OWVerticalSpacing {
        switch self {
        case .regular:
            return OWVerticalSpacing(top: Metrics.defaultSpaceBetweenComments, bottom: 10)
        }
    }

    var communityGuidelines: OWVerticalSpacing {
        switch self {
        case .regular:
            return OWVerticalSpacing(Metrics.defaultSpaceCommunityGuidelines)
        }
    }

    var communityQuestions: OWVerticalSpacing {
        switch self {
        case .regular:
            return OWVerticalSpacing(Metrics.defaultSpaceCommunityQuestions)
        }
    }

    var threadActionSpacing: OWVerticalSpacing {
        switch self {
        case .regular:
            return OWVerticalSpacing(bottom: 22)
        }
    }
}

extension OWPreConversationSpacing: Equatable {
    public static func == (lhs: OWPreConversationSpacing, rhs: OWPreConversationSpacing) -> Bool {
        switch (lhs, rhs) {
        case (.regular, .regular):
            return true
        }
    }
}
