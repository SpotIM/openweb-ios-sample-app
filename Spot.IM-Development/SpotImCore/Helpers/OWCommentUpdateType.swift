//
//  OWCommentUpdateType.swift
//  SpotImCore
//
//  Created by Alon Shprung on 10/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWCommentUpdateType {
    case insert(comments: [OWComment])
    case insertRealtime(comments: [OWComment]) // Should removed when new comments from comment creation will be also highlighted
    case update(commentId: OWCommentId, withComment: OWComment)
    case insertReply(comment: OWComment, toParentCommentId: OWCommentId)
}
