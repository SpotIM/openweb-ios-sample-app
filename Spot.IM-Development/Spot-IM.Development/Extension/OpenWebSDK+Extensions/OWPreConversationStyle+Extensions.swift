//
//  OWPreConversationStyle+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 28/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API

extension OWPreConversationStyle {
    static func preConversationStyle(fromIndex index: Int, numberOfComments: Int = OWPreConversationStyle.Metrics.defaultRegularNumberOfComments) -> OWPreConversationStyle {
        switch index {
        case 0: return .regular(numberOfComments: numberOfComments)
        case 1: return .compact
        case 2: return .ctaButtonOnly
        case 3: return .ctaWithSummary
        default: return `default`
        }
    }

    static var `default`: OWPreConversationStyle {
        return .regular()
    }

    enum CodingKeys: String, CodingKey {
        case regular
        case compact
        case ctaButtonOnly
        case ctaWithSummary
    }
}

#endif
