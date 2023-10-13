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
    func set(comments: [OWComment], postId: OWPostId)

    func cleanCache()
}

class OWCommentsService: OWCommentsServicing {

    // Multiple threads / queues access to this class
    // Avoiding "data race" by using a lock
    fileprivate let lock: OWLock = OWUnfairLock()

    fileprivate var _mapPostIdToComments = [OWPostId: OWCommentsMapper]()

    func get(commentId id: String, postId: String) -> OWComment? {
        self.lock.lock(); defer { self.lock.unlock() }

        guard let comments = _mapPostIdToComments[postId],
              let comment = comments[id]
        else { return nil }

        return comment
    }

    func set(comments: [OWComment], postId: OWPostId) {
        self.lock.lock(); defer { self.lock.unlock() }

        // Using `internalSet` function to avoid deadlock
        internalSet(comments: comments, postId: postId)
    }

    func cleanCache() {
        self.lock.lock(); defer { self.lock.unlock() }

        _mapPostIdToComments.removeAll()
    }
}

fileprivate extension OWCommentsService {
    func internalSet(comments: [OWComment], postId: OWPostId) {
        let commentIdToCommentTupples: [(String, OWComment)] = comments.map {
            guard let id = $0.id else { return nil }
            return (id, $0)
        }.unwrap()
        let commentIdsToComment: OWCommentsMapper = Dictionary(uniqueKeysWithValues: commentIdToCommentTupples)

        if let existingCommentsForPostId = _mapPostIdToComments[postId] {
            // merge and replacing current comments
            let newPostIdComments: OWCommentsMapper = existingCommentsForPostId.merging(commentIdsToComment, uniquingKeysWith: {(_, new) in new })
            _mapPostIdToComments[postId] = newPostIdComments
        } else {
            _mapPostIdToComments[postId] = commentIdsToComment
        }

        // add each comment replies as well
        comments.forEach {
            if let commentReplies = $0.replies {
                internalSet(comments: commentReplies, postId: postId)
            }
        }
    }
}
