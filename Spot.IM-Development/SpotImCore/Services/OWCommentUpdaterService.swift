//
//  OWCommentUpdaterService.swift
//  SpotImCore
//
//  Created by Alon Shprung on 02/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentUpdaterServicing {
    func update(_ updateType: OWCommentUpdateType, postId: OWPostId)
    func getUpdatedComments(for postId: OWPostId) -> Observable<OWCommentUpdateType>
}

class OWCommentUpdaterService: OWCommentUpdaterServicing {
    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate var _updatedCommentsWithPostId = PublishSubject<(OWCommentUpdateType, OWPostId)>()

    fileprivate lazy var _updatedCommentsWithPostIdShared: Observable<(OWCommentUpdateType, OWPostId)> = {
        _updatedCommentsWithPostId
            .asObservable()
            .share()
    }()

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }

    func update(_ updateType: OWCommentUpdateType, postId: OWPostId) {
        self._updatedCommentsWithPostId.onNext((updateType, postId))
        self.cacheUpdatedComments(for: updateType, postId: postId)
    }

    func getUpdatedComments(for postId: OWPostId) -> RxSwift.Observable<OWCommentUpdateType> {
        return _updatedCommentsWithPostIdShared
            .filter { $0.1 == postId }
            .map { $0.0 }
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
        case .insertReply(let comment, let parentCommentId):
            commentsToCache = [comment]
            if var parentComment = self.servicesProvider.commentsService().get(commentId: parentCommentId, postId: postId) {
                if let replies = parentComment.replies {
                    // Take other replieas from cash to keep local changes
                    let updatedReplies = replies.map { self.servicesProvider.commentsService().get(commentId: $0.id ?? "", postId: postId) }.unwrap()
                    parentComment.replies = [comment] + updatedReplies
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
