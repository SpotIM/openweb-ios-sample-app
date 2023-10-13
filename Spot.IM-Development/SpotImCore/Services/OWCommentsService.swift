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

        let commentIdToCommentTupples: [(String, OWComment)] = comments.map {
            guard let id = $0.id else { return nil }
            return (id, $0)
        }.unwrap()
        let commentIdsToComment: OWCommentsMapper = Dictionary(uniqueKeysWithValues: commentIdToCommentTupples)

        let queueName = self.queueName()
        let log = "Alon - Inside `set(comments`, \(queueName)"
        print(log)

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
                set(comments: commentReplies, postId: postId)
            }
        }
    }

    func cleanCache() {
        _mapPostIdToComments.removeAll()
    }
}

fileprivate extension OWCommentsService {
    func queueName() -> String {
        if let currentOperationQueue = OperationQueue.current {
            if let currentDispatchQueue = currentOperationQueue.underlyingQueue {
                return "dispatch queue: \(currentDispatchQueue.label.nonEmpty ?? currentDispatchQueue.description)"
            } else {
                return "operation queue: \(currentOperationQueue.name?.nonEmpty ?? currentOperationQueue.description)"
            }
        } else {
            let currentThread = Thread.current
            return "UNKNOWN QUEUE on thread: \(currentThread.name?.nonEmpty ?? currentThread.description)"
        }
    }
}

fileprivate extension String {
    /// Returns this string if it is not empty, else `nil`.
    var nonEmpty: String? {
        if self.isEmpty {
            return nil
        } else {
            return self
        }
    }
}
