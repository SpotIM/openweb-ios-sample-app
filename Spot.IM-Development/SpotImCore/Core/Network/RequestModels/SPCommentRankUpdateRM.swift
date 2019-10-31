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
    var subject: SPRank

    var reversed: SPRankChange {
        return SPRankChange(from: self.to, to: self.from, subject: subject)
    }
}

enum SPRank: Int {
    case up = 1
    case unrank = 0
    case down = -1
}
