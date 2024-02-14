//
//  OWCommentDelete.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 28/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

struct OWCommentDelete: Decodable {

    let id: String?
    let conversationId: String?
    let etag: Int?
    let messagesCount: Int?
    let commentsCount: Int?
    let softDeleted: Bool?

}
