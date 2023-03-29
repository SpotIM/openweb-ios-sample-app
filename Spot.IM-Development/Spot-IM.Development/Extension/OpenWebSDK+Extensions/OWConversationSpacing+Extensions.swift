//
//  OWConversationSpacing+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 23/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API

extension OWConversationSpacing {
    init(index: Int, betweenComments: CGFloat, belowHeader: CGFloat, belowCommunityGuidelines: CGFloat, belowCommunityQuestions: CGFloat) {
        switch index {
        case 0: self = .regular
        case 1: self = .compact
        case 2: self = .custom(betweenComments: betweenComments,
                               belowHeader: belowHeader,
                               belowCommunityGuidelines: belowCommunityGuidelines,
                               belowCommunityQuestions: belowCommunityQuestions)
        default:
            self = .regular
        }
    }

    // Validate and correct spacing inputs from setting's text fields
    static func validateSpacing(_ spacing: String) -> CGFloat {
        if let number = NumberFormatter().number(from: spacing) {
            let cgFloat = CGFloat(truncating: number)
            if cgFloat > OWConversationSpacing.Metrics.maxSpace {
                return OWConversationSpacing.Metrics.maxSpace
            } else if cgFloat < OWConversationSpacing.Metrics.minSpace {
                return OWConversationSpacing.Metrics.minSpace
            }
            return cgFloat
        }
        return OWConversationSpacing.Metrics.defaultSpaceBelowHeader
    }

    static var defaultIndex: Int {
        return 0
    }

    enum CodingKeys: String, CodingKey {
        case regular
        case compact
        case custom
    }
}

#endif
