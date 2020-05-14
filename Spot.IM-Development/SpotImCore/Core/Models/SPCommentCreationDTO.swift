//
//  SPCommentCreationDTO.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/1/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

struct SPCommentCreationDTO {
    let articleMetadata: SpotImArticleMetadata
    let currentUserAvatar: URL?
    let postId: String
    let displayName: String
    let converstionId: String
    let user: SPUser?
}

struct SPReplyCreationDTO {
    
    let currentUserAvatar: URL?
    let authorName: String?
    let comment: String?
    let commentId: String
    let postId: String
    let displayName: String
    let rootCommentId: String?
    let parentDepth: Int?
    let user: SPUser?
    
}
