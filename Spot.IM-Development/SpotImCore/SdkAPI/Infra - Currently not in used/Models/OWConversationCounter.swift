//
//  OWConversationCounter.swift
//  SpotImCore
//
//  Created by Alon Haiut on 21/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWConversationCounter: Codable {
    public let commentsNumber: Int
    public let repliesNumber: Int

    enum CodingKeys: String, CodingKey {
        case commentsNumber = "comments"
        case repliesNumber = "replies"
    }
}

#else
struct OWConversationCounter: Codable {
    let commentsNumber: Int
    let repliesNumber: Int

    enum CodingKeys: String, CodingKey {
        case commentsNumber = "comments"
        case repliesNumber = "replies"
    }
}
#endif
