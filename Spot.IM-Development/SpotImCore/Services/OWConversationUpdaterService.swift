//
//  OWConversationUpdaterService.swift
//  SpotImCore
//
//  Created by Alon Shprung on 02/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWConversationUpdaterServicing {
    func update(_ updateType: OWConversationUpdateType, postId: OWPostId)
    func getConversationUpdates(for postId: OWPostId) -> Observable<OWConversationUpdateType>
}

class OWConversationUpdaterService: OWConversationUpdaterServicing {
    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate var _conversationUpdatesWithPostId = PublishSubject<(OWConversationUpdateType, OWPostId)>()

    fileprivate lazy var _conversationUpdatesWithPostIdShared: Observable<(OWConversationUpdateType, OWPostId)> = {
        _conversationUpdatesWithPostId
            .asObservable()
            .share()
    }()

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }

    func update(_ updateType: OWConversationUpdateType, postId: OWPostId) {
        self.cacheUpdatedComments(for: updateType, postId: postId)
        self._conversationUpdatesWithPostId.onNext((updateType, postId))
    }

    func getConversationUpdates(for postId: OWPostId) -> Observable<OWConversationUpdateType> {
        return _conversationUpdatesWithPostIdShared
            .filter { $0.1 == postId }
            .map { $0.0 }
    }
}

fileprivate extension OWConversationUpdaterService {
    func cacheUpdatedComments(for updateType: OWConversationUpdateType, postId: OWPostId) {
        let commentsToCache: [OWComment]
        switch updateType {
        case .refreshConversation:
            commentsToCache = []
        case .insert(let comments), .insertRealtime(let comments):
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
        if (!commentsToCache.isEmpty) {
            self.servicesProvider.commentsService().set(comments: commentsToCache, postId: postId)
        }
    }
}
