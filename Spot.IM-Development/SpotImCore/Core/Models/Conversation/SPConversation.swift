//
//  SPConversation.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 21/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal struct SPConversation: Decodable {
    var sortBy: String?
    var messagesCount: Int?
    var offset: Int?
    var hasNext: Bool = false
    var maxDepth: Int?
    var communityQuestion: String?

    var users: [String: SPUser]?
    var comments: [SPComment]?
}
