//
//  SPCommentDelete.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/27/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

struct SPCommentDelete: Decodable {

    let id: String?
    let conversationId: String?
    let etag: Int?
    let messagesCount: Int?
    let commentsCount: Int?
    let softDeleted: Bool?

}
