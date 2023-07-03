//
//  OWReportedCommentsService.swift
//  SpotImCore
//
//  Created by Alon Shprung on 03/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

typealias OWReportedCommentIds = Set<OWCommentId>

protocol OWReportedCommentsServicing {
    func getUpdatedStatus(for comment: OWComment, postId: OWPostId) -> OWComment
    func set(reportedCommentIds ids: [OWCommentId], postId: OWPostId)

    func cleanCache()
}

class OWReportedCommentsService: OWReportedCommentsServicing {

    fileprivate var _mapPostIdToReportedCommentIds = [OWPostId: OWReportedCommentIds]()

    func set(reportedCommentIds ids: [OWCommentId], postId: OWPostId) {
        if let existingCommentIdsForPostId = _mapPostIdToReportedCommentIds[postId] {
            // merge and replacing current comments
            _mapPostIdToReportedCommentIds[postId] = existingCommentIdsForPostId.union(ids)
        } else {
            _mapPostIdToReportedCommentIds[postId] = Set(ids)
        }
    }

    func getUpdatedStatus(for comment: OWComment, postId: OWPostId) -> OWComment {
        guard let commentId = comment.id else { return comment }
        var updatedComment = comment
        if (comment.status == .pending || comment.status == .unknown) && isReported(commentId: commentId, postId: postId) {
            updatedComment.setIsReported(true)
        }
        return updatedComment
    }

    func cleanCache() {
        self._mapPostIdToReportedCommentIds.removeAll()
    }
}

fileprivate extension OWReportedCommentsService {
    func isReported(commentId id: OWCommentId, postId: OWPostId) -> Bool {
        return _mapPostIdToReportedCommentIds[postId]?.contains(id) ?? false
    }
}
