//
//  OWRealTimeMessagesCount.swift
//  SpotImCore
//
//  Created by Revital Pisman on 06/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWRealTimeMessagesCount: Decodable {
    let replies: Int
    let comments: Int

    enum CodingKeys: String, CodingKey {
        case replies = "Replies"
        case comments = "Comments"
    }
}
