//
//  OWConversation.swift
//  SpotImCore
//
//  Created by Alon Shprung on 10/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

internal struct OWConversation: Decodable {
    var sortBy: String?
    var messagesCount: Int?
    var offset: Int?
    var hasNext: Bool = false
    var maxDepth: Int?
    var communityQuestion: String?
    var readOnly: Bool = false

    var users: [String: SPUser]?
    var comments: [OWComment]?
}
