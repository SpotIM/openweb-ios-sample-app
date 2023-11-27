//
//  OWCommentThreadPerformActionType.swift
//  SpotImCore
//
//  Created by Alon Shprung on 22/11/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWCommentThreadPerformActionType {
    case none
    case changeRank(from: Int, to: Int)
}

#else
enum OWCommentThreadPerformActionType {
    case none
    case changeRank(from: Int, to: Int)
}
#endif
