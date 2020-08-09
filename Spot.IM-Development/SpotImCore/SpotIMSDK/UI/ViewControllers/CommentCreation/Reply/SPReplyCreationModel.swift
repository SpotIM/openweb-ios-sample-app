//
//  SPReplyCreationModel.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/7/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

final class SPReplyCreationModel: CommentStateable {
    
    private(set) var commentText: String = ""
    var postCompletionHandler: ((SPComment) -> Void)?
    var postErrorHandler: ((Error) -> Void)?
    
    let dataModel: SPReplyCreationDTO
    
    private let cacheService: SPCommentsInMemoryCacheService
    private let commentService: SPCommentUpdater
    private let imageProvider: SPImageURLProvider
    
    init(replyCreationDTO: SPReplyCreationDTO,
         cacheService: SPCommentsInMemoryCacheService,
         updater: SPCommentUpdater,
         imageProvider: SPImageURLProvider
        ) {
        self.imageProvider = imageProvider
        self.cacheService = cacheService
        commentText = cacheService.comment(for: replyCreationDTO.commentId)
        dataModel = replyCreationDTO
        commentService = updater
    }
    
    func fetchNavigationAvatar(completion: @escaping ImageLoadingCompletion) {
        imageProvider.image(with: SPUserSessionHolder.session.user?.imageURL(size: navigationAvatarSize),
                            size: navigationAvatarSize,
                            completion: completion)
    }
    
    func updateCommentText(_ text: String) {
        commentText = text
        cacheService.update(comment: text, with: dataModel.commentId)
    }
    
    func post() {
       
        let parameters = postParameters()
        
        commentService.createComment(
            parameters: parameters,
            postId: dataModel.postId,
            success: { [weak self] reply in
                guard let self = self else { return }
                
                var reply = reply
                reply.writtenAt = Date().timeIntervalSince1970
                reply.rootComment = self.dataModel.rootCommentId
                reply.parentId = self.dataModel.commentId
                reply.depth = (self.dataModel.parentDepth ?? 0) + 1
                let userId = SPUserSessionHolder.session.user?.id
                reply.userId = userId
                if let userId = reply.userId {
                    let user = SPComment.CommentUser(id: userId)
                    reply.users = [userId: user]
                }
                self.cacheService.remove(for: self.dataModel.commentId)
                self.postCompletionHandler?(reply)
            },
            failure: { [weak self] error in
                self?.postErrorHandler?(error)
            }
        )
    }

    private func postParameters() -> [String: Any] {
        
        let userId = SPUserSessionHolder.session.user?.displayName ?? dataModel.displayName
        
        var metadata: [String: Any] = [
            CreateReplyAPIKeys.displayName: userId
        ]
        
        let isRootComment = dataModel.commentId == dataModel.rootCommentId
        if !isRootComment {
            metadata[CreateReplyAPIKeys.replyTo] = [CreateReplyAPIKeys.replyId: dataModel.commentId]
        }
        
        return [
            CreateReplyAPIKeys.parentId: dataModel.rootCommentId ?? dataModel.commentId,
            CreateReplyAPIKeys.conversationId: dataModel.postId,
            CreateReplyAPIKeys.content: [
                [CreateReplyAPIKeys.text: commentText]
            ],
            CreateReplyAPIKeys.metadata: metadata
        ]
    }
    
    private enum CreateReplyAPIKeys {
        static let content = "content"
        static let text = "text"
        static let metadata = "metadata"
        static let displayName = "display_name"
        static let parentId = "parent_id"
        static let conversationId = "conversation_id"
        static let replyTo = "reply_to"
        static let replyId = "reply_id"
    }
    
}
