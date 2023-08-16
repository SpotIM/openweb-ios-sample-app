//
//  SPRankChange+Analytics.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

extension SPRankChange {
    func analyticsEventType(commentId: String) -> OWAnalyticEventType? {
        switch (self.from, self.to) {
        case (_, .up): return .commentRankUpButtonClicked(commentId: commentId)
        case (.up, .unrank): return .commentRankUpUndoButtonClicked(commentId: commentId)
        case (_, .down): return .commentRankDownButtonClicked(commentId: commentId)
        case (.down, .unrank): return .commentRankDownUndoButtonClicked(commentId: commentId)
        default: return nil
        }
    }
}
