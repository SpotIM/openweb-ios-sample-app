//
//  OWConversationSpacing+Extensions.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 23/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK

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
    static func validateSpacing(_ spacing: String) -> CGFloat {
        guard let spacingDouble = Double(spacing) else {
            // Return a default value or handle the error if the conversion fails
            return OWConversationSpacing.Metrics.minSpace
        }

        let cgFloatSpacing = CGFloat(spacingDouble)
        return min(max(cgFloatSpacing, Metrics.minSpace), Metrics.maxSpace)
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
