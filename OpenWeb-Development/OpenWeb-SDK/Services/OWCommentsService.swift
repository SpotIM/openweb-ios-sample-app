//
//  OWCommentsService.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 19/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
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
        // swiftlint:disable self_capture_in_blocks
        self.lock.lock(); defer { self.lock.unlock() }
        // swiftlint:enable self_capture_in_blocks

        guard let comments = _mapPostIdToComments[postId],
              let comment = comments[id]
        else { return nil }

        return comment
    }

    func set(comments: [OWComment], postId: OWPostId) {
        // swiftlint:disable self_capture_in_blocks
        self.lock.lock(); defer { self.lock.unlock() }
        // swiftlint:enable self_capture_in_blocks

        // Using `internalSet` function to avoid deadlock
        internalSet(comments: comments, postId: postId)
    }

    func cleanCache() {
        // swiftlint:disable self_capture_in_blocks
        self.lock.lock(); defer { self.lock.unlock() }
        // swiftlint:enable self_capture_in_blocks

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
