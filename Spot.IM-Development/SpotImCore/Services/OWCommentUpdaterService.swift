//
//  OWCommentUpdaterService.swift
//  SpotImCore
//
//  Created by Alon Shprung on 02/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

enum OWCommentUpdateType {
    case insert(comments: [OWComment])
    case update(commentId: OWCommentId, withComment: OWComment)
    case reply(comment: OWComment, toCommentId: OWCommentId)
}

protocol OWCommentUpdaterServicing {
    func update(_ updateType: OWCommentUpdateType, postId: OWPostId)
    func getUpdatedComments(for postId: OWPostId) -> Observable<OWCommentUpdateType>
}

class OWCommentUpdaterService: OWCommentUpdaterServicing {
    fileprivate var _updatedCommentsWithPostId = PublishSubject<(OWCommentUpdateType, OWPostId)>()
    fileprivate var servicesProvider: OWSharedServicesProviding

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }

    func update(_ updateType: OWCommentUpdateType, postId: OWPostId) {
        self._updatedCommentsWithPostId.onNext((updateType, postId))
        self.cacheUpdatedComments(for: updateType, postId: postId)
    }

    func getUpdatedComments(for postId: OWPostId) -> RxSwift.Observable<OWCommentUpdateType> {
        return _updatedCommentsWithPostId
            .filter { $0.1 == postId }
            .map { $0.0 }
            .asObservable()
    }
}

fileprivate extension OWCommentUpdaterService {
    func cacheUpdatedComments(for updateType: OWCommentUpdateType, postId: OWPostId) {
        let commentsToCache: [OWComment]
        switch updateType {
        case .insert(let comments):
            commentsToCache = comments
        case .update(_, let withComment):
            commentsToCache = [withComment]
        case .reply(let comment, let parentCommentId):
            commentsToCache = [comment]
            if var parentComment = self.servicesProvider.commentsService().get(commentId: parentCommentId, postId: postId) {
                if let replies = parentComment.replies {
                    parentComment.replies = [comment] + replies
                } else {
                    parentComment.replies = [comment]
                }
                parentComment.repliesCount = (parentComment.repliesCount ?? 0) + 1
                parentComment.totalRepliesCount = (parentComment.totalRepliesCount ?? 0) + 1
                self.servicesProvider.commentsService().set(comments: [parentComment], postId: postId)
            }
        }
        self.servicesProvider.commentsService().set(comments: commentsToCache, postId: postId)
    }
}
