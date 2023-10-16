//
//  OWReportedCommentsService.swift
//  SpotImCore
//
//  Created by Alon Shprung on 03/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

fileprivate typealias OWReportedCommentIds = Set<OWCommentId>

protocol OWReportedCommentsServicing {
    func getUpdatedComment(for originalComment: OWComment, postId: OWPostId) -> OWComment
    func updateCommentReportedSuccessfully(commentId: OWCommentId, postId: OWPostId)
    func updateReportedComments(commentsIds: [OWCommentId], postId: OWPostId)
    var commentJustReported: Observable<OWCommentId> { get }

    func cleanCache()
}

class OWReportedCommentsService: OWReportedCommentsServicing {

    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate var _mapPostIdToReportedCommentIds = [OWPostId: OWReportedCommentIds]() {
        didSet {
            savePersistant()
        }
    }
    fileprivate var _commentJustReported = PublishSubject<OWCommentId>()

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        loadPersistence()
    }

    func getUpdatedComment(for originalComment: OWComment, postId: OWPostId) -> OWComment {
        guard let commentId = originalComment.id else { return originalComment }
        var updatedComment = originalComment
        if (originalComment.status == .pending || originalComment.status == .unknown) && isReported(commentId: commentId, postId: postId) {
            updatedComment.setIsReported(true)
        }
        return updatedComment
    }

    func updateCommentReportedSuccessfully(commentId: OWCommentId, postId: OWPostId) {
        set(reportedCommentIds: [commentId], postId: postId)
        _commentJustReported.onNext(commentId)
    }

    func updateReportedComments(commentsIds: [OWCommentId], postId: OWPostId) {
        set(reportedCommentIds: commentsIds, postId: postId)
    }

    var commentJustReported: Observable<OWCommentId> {
        return _commentJustReported
            .share()
    }

    func cleanCache() {
        self._mapPostIdToReportedCommentIds.removeAll()
    }
}

fileprivate extension OWReportedCommentsService {
    func set(reportedCommentIds ids: [OWCommentId], postId: OWPostId) {
        if let existingCommentIdsForPostId = _mapPostIdToReportedCommentIds[postId] {
            // merge and replacing current comments
            _mapPostIdToReportedCommentIds[postId] = existingCommentIdsForPostId.union(ids)
        } else {
            _mapPostIdToReportedCommentIds[postId] = Set(ids)
        }
        updateCommentsService(with: ids, postId: postId)
    }

    func updateCommentsService(with reportedCommentIds: [OWCommentId], postId: OWPostId) {
        reportedCommentIds.forEach { commentId in
            let commentsService = self.servicesProvider.commentsService()
            if var existingComment = commentsService.get(commentId: commentId, postId: postId) {
                existingComment.setIsReported(true)
                commentsService.set(comments: [existingComment], postId: postId)
            }
        }
    }

    func isReported(commentId id: OWCommentId, postId: OWPostId) -> Bool {
        return _mapPostIdToReportedCommentIds[postId]?.contains(id) ?? false
    }

    func loadPersistence() {
        let keychain = servicesProvider.keychain()

        if let reportedCommentsMapper = keychain.get(key: OWKeychain.OWKey<[OWPostId: OWReportedCommentIds]>.reportedComments) {
            self._mapPostIdToReportedCommentIds = reportedCommentsMapper
        }
    }

    func savePersistant() {
        let keychain = servicesProvider.keychain()

        keychain.save(value: _mapPostIdToReportedCommentIds, forKey: OWKeychain.OWKey<[OWPostId: OWReportedCommentIds]>.reportedComments)
    }
}
