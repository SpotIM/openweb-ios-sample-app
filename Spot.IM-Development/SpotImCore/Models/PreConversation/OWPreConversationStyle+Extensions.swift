//
//  OWPreConversationStyle+Extensions.swift
//  SpotImCore
//
//  Created by Alon Haiut on 31/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

extension OWPreConversationStyle {
    struct InternalMetrics {
        static let numberOfCommentsForCompactStyle: Int = 1
    }

    func validate() -> OWPreConversationStyle {
        guard case let .regular(numberOfComments, _) = self else { return self }
        if (numberOfComments > Metrics.maxNumberOfComments) || (numberOfComments < Metrics.minNumberOfComments) {
            return .regular()
        } else {
            return self
        }
    }

    var numberOfComments: Int {
        switch self {
        case .regular(let numOfComments, _):
            return numOfComments
        case .compact:
            return InternalMetrics.numberOfCommentsForCompactStyle
        default:
            return 0
        }
    }

    var collapsableTextLineLimit: Int {
        switch self {
        case .regular(_, let lineLimit):
            return lineLimit
        case .compact(let lineLimit):
            return lineLimit
        default:
            return Metrics.defaultCollapsableTextLineLimit
        }
    }
}
