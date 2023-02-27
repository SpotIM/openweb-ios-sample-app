//
//  OWConversationSpacing+Extension.swift
//  SpotImCore
//
//  Created by Alon Haiut on 31/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

// Fileprivate because the use case is for validation only
fileprivate enum OWConversationSpaceType {
    case betweenComments
    case belowHeader
    case belowCommunityGuidelines
    case belowCommunityQuestions

    var defaultSpace: CGFloat {
        switch self {
        case .betweenComments:
            return OWConversationSpacing.Metrics.defaultSpaceBetweenComments
        case .belowHeader:
            return OWConversationSpacing.Metrics.defaultSpaceBelowHeader
        case .belowCommunityGuidelines:
            return OWConversationSpacing.Metrics.defaultSpaceBelowCommunityGuidelines
        case .belowCommunityQuestions:
            return OWConversationSpacing.Metrics.defaultSpaceBelowCommunityQuestions
        }
    }
}

extension OWConversationSpacing {
    func validate() -> OWConversationSpacing {
        guard case let .custom(betweenComments, belowHeader, belowCommunityGuidelines, belowCommunityQuestions) = self else { return self }

        var spacesDictionary: [OWConversationSpaceType: CGFloat] = [.betweenComments: betweenComments,
                                                                 .belowHeader: belowHeader,
                                                                 .belowCommunityGuidelines: belowCommunityGuidelines,
                                                                 .belowCommunityQuestions: belowCommunityQuestions]

        spacesDictionary.forEach { space in
            if (space.value > Metrics.maxSpace) || (space.value < Metrics.minSpace) {
                spacesDictionary[space.key] = space.key.defaultSpace
            }
        }

        let newCustom: OWConversationSpacing = .custom(betweenComments: spacesDictionary[.betweenComments] ?? Metrics.minSpace,
                                                       belowHeader: spacesDictionary[.belowHeader] ?? Metrics.minSpace,
                                                       belowCommunityGuidelines: spacesDictionary[.belowCommunityGuidelines] ?? Metrics.minSpace,
                                                       belowCommunityQuestions: spacesDictionary[.belowCommunityQuestions] ?? Metrics.minSpace)

        return newCustom
    }
}
