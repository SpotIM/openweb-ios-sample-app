//
//  OWConversationCounter.swift
//  SpotImCore
//
//  Created by Alon Haiut on 21/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWConversationCounter {
    public let commentsNumber: Int
    public let repliesNumber: Int
}

#else
struct OWConversationCounter {
    let commentsNumber: Int
    let repliesNumber: Int
}
#endif
