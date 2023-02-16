//
//  SPCommentRankUpdateRM.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 08/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

struct SPRankChange {
    var from: SPRank
    var to: SPRank

    var reversed: SPRankChange {
        return SPRankChange(from: self.to, to: self.from)
    }

    var operation: String? {
        switch (self.from, self.to) {
            case (_, .up): return "like"
            case (.up, .unrank): return "toggle-like"
            case (_, .down): return "dislike"
            case (.down, .unrank): return "toggle-dislike"
            default: return nil
        }
    }
}

enum SPRank: Int {
    case up = 1
    case unrank = 0
    case down = -1
}
