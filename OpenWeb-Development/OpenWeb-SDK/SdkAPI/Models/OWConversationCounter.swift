//
//  OWConversationCounter.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 21/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

public struct OWConversationCounter: Codable {
    public let commentsNumber: Int
    public let repliesNumber: Int

    enum CodingKeys: String, CodingKey {
        case commentsNumber = "comments"
        case repliesNumber = "replies"
    }
}
