//
//  OWRealtimeIndicatorType.swift
//  SpotImCore
//
//  Created by Revital Pisman on 02/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWRealtimeIndicatorType: Equatable {
    case typing(count: Int)
    case newComments(count: Int)
    case all(typingCount: Int, newCommentsCount: Int)
    case none

    static func == (lhs: OWRealtimeIndicatorType, rhs: OWRealtimeIndicatorType) -> Bool {
        switch (lhs, rhs) {
        case (.typing(let lhsCount), .typing(let rhsCount)):
            return lhsCount == rhsCount
        case (.newComments(let lhsCount), .newComments(let rhsCount)):
            return lhsCount == rhsCount
        case (.all(let lhsTypingCount, let lhsNewCommentsCount),
              .all(let rhsTypingCount, let rhsNewCommentsCount)):
            return lhsTypingCount == rhsTypingCount && lhsNewCommentsCount == rhsNewCommentsCount
        case (.none, .none):
            return true
        default:
            return false
        }
    }
}
