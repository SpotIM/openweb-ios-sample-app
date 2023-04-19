//
//  OWCommentsService.swift
//  SpotImCore
//
//  Created by Alon Shprung on 19/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

internal protocol OWCommentsServicing {
    func getComment(with id: String, postId: String) -> OWComment?
    func setComments(_ comments: [OWComment], postId: String)

    func cleanCachedComments()
}

class OWCommentsService: OWCommentsServicing {

    private var _mapPostIdToComments = [OWPostId: [String: OWComment]]()

    func getComment(with id: String, postId: String) -> OWComment? {
        guard let comments = _mapPostIdToComments[postId],
              let comment = comments[id]
        else { return nil }
        return comment
    }

    func setComments(_ comments: [OWComment], postId: String) {
        let commentIdsToComment: [String: OWComment] = Dictionary(uniqueKeysWithValues: comments.map { ($0.id!, $0) })

        if var existingCommentsForPostId = _mapPostIdToComments[postId] {
            // merge and replacing current comments
            _mapPostIdToComments[postId] = existingCommentsForPostId.merging(commentIdsToComment, uniquingKeysWith: {(_, new) in new })
        } else {
            _mapPostIdToComments[postId] = commentIdsToComment
        }

        // add each comment replies as well
        comments.forEach {
            if let commentReplies = $0.replies {
                setComments(commentReplies, postId: postId)
            }
        }
    }

    func cleanCachedComments() {
        _mapPostIdToComments.removeAll()
    }
}
