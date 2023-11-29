//
//  SPCommentSortMode.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 23/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal enum SPCommentSortMode: String, CaseIterable, Decodable {

    case best
    case newest
    case oldest
}
