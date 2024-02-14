//
//  OWCachedCommentKey.swift
//  SpotImCore
//
//  Created by Alon Shprung on 30/07/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

enum OWCachedCommentKey: Hashable {
    case comment(postId: OWPostId)
    case reply(postId: OWPostId, commentId: OWCommentId)
    case edit(postId: OWPostId)
}

extension OWCachedCommentKey: Equatable {
    static func == (lhs: OWCachedCommentKey, rhs: OWCachedCommentKey) -> Bool {
        switch (lhs, rhs) {
        case (let .comment(lhsPostId), let .comment(rhsPostId)):
            return lhsPostId == rhsPostId
        case (let .reply(lhsPostId, lhsCommentId), let .reply(rhsPostId, rhsCommentId)):
            return lhsPostId == rhsPostId && lhsCommentId == rhsCommentId
        case (let .edit(lhsPostId), let .edit(rhsPostId)):
            return lhsPostId == rhsPostId
        default: return false
        }
    }
}
