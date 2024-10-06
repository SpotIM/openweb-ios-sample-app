//
//  OWReportedCommentsService.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 03/07/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

private typealias OWReportedCommentIds = Set<OWCommentId>

protocol OWReportedCommentsServicing {
    func getUpdatedComment(for originalComment: OWComment, postId: OWPostId) -> OWComment
    func updateCommentReportedSuccessfully(commentId: OWCommentId, postId: OWPostId)
    func updateReportedComments(forConversationResponse conversationResponse: OWConversationReadRM, postId: OWPostId)
    var commentJustReported: Observable<OWCommentId> { get }

    func cleanCache()
}

class OWReportedCommentsService: OWReportedCommentsServicing {

    private unowned let servicesProvider: OWSharedServicesProviding
    private var _mapPostIdToReportedCommentIds = [OWPostId: OWReportedCommentIds]()
    private var _commentJustReported = PublishSubject<OWCommentId>()

    // Multiple threads / queues access to this class
    // Avoiding "data race" by using a lock
    private let lock: OWLock = OWUnfairLock()
    private let queue = DispatchQueue(label: "OpenWebSDKReportedCommentsService", qos: .utility)

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        loadPersistence()
    }

    func getUpdatedComment(for originalComment: OWComment, postId: OWPostId) -> OWComment {
        guard let commentId = originalComment.id else { return originalComment }
        var updatedComment = originalComment
        if (originalComment.status == .pending || originalComment.status == .unknown || originalComment.status == nil)
            && isReported(commentId: commentId, postId: postId) {
            updatedComment.setIsReported(true)
        }
        return updatedComment
    }

    func updateCommentReportedSuccessfully(commentId: OWCommentId, postId: OWPostId) {
        set(reportedCommentIds: [commentId], postId: postId)
        _commentJustReported.onNext(commentId)
    }

    func updateReportedComments(forConversationResponse conversationResponse: OWConversationReadRM, postId: OWPostId) {
        if let reported = conversationResponse.reportedComments {
            let reportedArray = Array(reported.keys)
            set(reportedCommentIds: reportedArray, postId: postId)
        }
    }

    var commentJustReported: Observable<OWCommentId> {
        return _commentJustReported
            .share()
    }

    func cleanCache() {
        // swiftlint:disable self_capture_in_blocks
        self.lock.lock(); defer { self.lock.unlock() }
        // swiftlint:enable self_capture_in_blocks

        self._mapPostIdToReportedCommentIds.removeAll()
        savePersistant()
    }
}

private extension OWReportedCommentsService {
    func set(reportedCommentIds ids: [OWCommentId], postId: OWPostId) {
        // swiftlint:disable self_capture_in_blocks
        self.lock.lock(); defer { self.lock.unlock() }
        // swiftlint:enable self_capture_in_blocks

        if let existingCommentIdsForPostId = _mapPostIdToReportedCommentIds[postId] {
            // merge and replacing current comments
            _mapPostIdToReportedCommentIds[postId] = existingCommentIdsForPostId.union(ids)
        } else {
            _mapPostIdToReportedCommentIds[postId] = Set(ids)
        }
        updateCommentsService(with: ids, postId: postId)
        savePersistant()
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
        // swiftlint:disable self_capture_in_blocks
        self.lock.lock(); defer { self.lock.unlock() }
        // swiftlint:enable self_capture_in_blocks
        return _mapPostIdToReportedCommentIds[postId]?.contains(id) ?? false
    }

    func loadPersistence() {
        queue.async { [weak self] in
            guard let self else { return }
            let keychain = self.servicesProvider.keychain()

            if let reportedCommentsMapper = keychain.get(key: OWKeychain.OWKey<[OWPostId: OWReportedCommentIds]>.reportedComments) {
                // swiftlint:disable self_capture_in_blocks
                self.lock.lock(); defer { self.lock.unlock() }
                // swiftlint:enable self_capture_in_blocks
                self._mapPostIdToReportedCommentIds = reportedCommentsMapper
            }
        }
    }

    func savePersistant() {
        queue.async { [weak self] in
            guard let self else { return }
            let keychain = self.servicesProvider.keychain()

            keychain.save(value: self._mapPostIdToReportedCommentIds, forKey: OWKeychain.OWKey<[OWPostId: OWReportedCommentIds]>.reportedComments)
        }
    }
}
