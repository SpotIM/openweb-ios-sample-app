//
//  SPBaseCommentCreationDTO.swift
//  SpotImCore
//
//  Created by Tomer Ben Rachel on 15/11/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation


struct SPBaseCommentCreationDTO {
    let articleMetadata: SpotImArticleMetadata
    let currentUserAvatarUrl: URL?
    let postId: String
    let displayName: String
    let user: SPUser?
    let replyModel: SPReplyCommentDTO?
}

struct SPReplyCommentDTO {
    let authorName: String?
    let commentText: String?
    let commentId: String
    let rootCommentId: String?
    let parentDepth: Int?
}
