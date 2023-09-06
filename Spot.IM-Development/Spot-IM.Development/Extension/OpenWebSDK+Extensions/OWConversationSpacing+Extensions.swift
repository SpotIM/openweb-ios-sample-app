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
    init(index: Int, betweenComments: CGFloat, communityGuidelines: CGFloat, communityQuestions: CGFloat) {
        switch index {
        case OWConversationSpacingIndexer.regular.index: self = .regular
        case OWConversationSpacingIndexer.compact.index: self = .compact
        case OWConversationSpacingIndexer.custom.index: self = .custom(betweenComments: betweenComments,
                                                                       communityGuidelines: communityGuidelines,
                                                                       communityQuestions: communityQuestions)
        default:
            self = .regular
        }
    }

    // Validate and correct spacing inputs from setting's text fields
    static func convertSpacing(_ spacing: String) -> CGFloat {
        guard let spacingDouble = Double(spacing) else {
            // Return a default value or handle the error if the conversion fails
            return OWConversationSpacing.Metrics.minSpace
        }

        return  CGFloat(spacingDouble)
    }

    static var defaultIndex: Int {
        return OWConversationSpacingIndexer.regular.index
    }

    enum CodingKeys: String, CodingKey {
        case regular
        case compact
        case custom
    }
}

#endif
