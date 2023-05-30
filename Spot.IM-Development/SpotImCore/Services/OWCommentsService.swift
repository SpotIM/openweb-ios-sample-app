//
//  OWCommentsService.swift
//  SpotImCore
//
//  Created by Alon Shprung on 19/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

typealias OWCommentsMapper = [String: OWComment]

protocol OWCommentsServicing {
    func get(commentId id: String, postId: String) -> OWComment?
    func set(comments: [OWComment], postId: String)

    func cleanCache()
}

class OWCommentsService: OWCommentsServicing {

    fileprivate var _mapPostIdToComments = [OWPostId: OWCommentsMapper]()

    func get(commentId id: String, postId: String) -> OWComment? {
        guard let comments = _mapPostIdToComments[postId],
              let comment = comments[id]
        else { return nil }
        return comment
    }

    func set(comments: [OWComment], postId: String) {
        let commentIdToCommentTupples: [(String, OWComment)] = comments.map {
            guard let id = $0.id else { return nil }
            return (id, $0)
        }.unwrap()
        let commentIdsToComment: OWCommentsMapper = Dictionary(uniqueKeysWithValues: commentIdToCommentTupples)

        if let existingCommentsForPostId = _mapPostIdToComments[postId] {
            // merge and replacing current comments
            _mapPostIdToComments[postId] = existingCommentsForPostId.merging(commentIdsToComment, uniquingKeysWith: {(_, new) in new })
        } else {
            _mapPostIdToComments[postId] = commentIdsToComment
        }

        // add each comment replies as well
        comments.forEach {
            if let commentReplies = $0.replies {
                set(comments: commentReplies, postId: postId)
            }
        }
    }

    func cleanCache() {
        _mapPostIdToComments.removeAll()
    }
}
