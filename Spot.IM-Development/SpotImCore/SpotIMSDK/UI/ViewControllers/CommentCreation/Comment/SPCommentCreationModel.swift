//
//  SPCommentCreationModel.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/1/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

protocol CommentStateable {
    
    var postCompletionHandler: ((SPComment) -> Void)? { get set }
    var commentText: String { get }
    
    func post()
    func updateCommentText(_ text: String)
    func fetchNavigationAvatar(completion: @escaping ImageLoadingCompletion)
}

final class SPCommentCreationModel: CommentStateable {
    
    private(set) var commentText: String = ""
    var postCompletionHandler: ((SPComment) -> Void)?
    var postErrorHandler: ((Error) -> Void)?
    
    let dataModel: SPCommentCreationDTO
    
    private let cacheService: SPCommentsInMemoryCacheService
    private let commentService: SPCommentUpdater
    private let imageProvider: SPImageURLProvider
    
    init(commentCreationDTO: SPCommentCreationDTO,
         cacheService: SPCommentsInMemoryCacheService,
         updater: SPCommentUpdater = SPCommentFacade(),
         imageProvider: SPImageURLProvider
        ) {
        self.imageProvider = imageProvider
        self.cacheService = cacheService
        commentText = cacheService.comment(for: commentCreationDTO.converstionId)
        dataModel = commentCreationDTO
        commentService = updater
    }
    
    func fetchNavigationAvatar(completion: @escaping ImageLoadingCompletion) {
        imageProvider.image(with: SPUserSessionHolder.session.user?.imageURL(size: navigationAvatarSize),
                            size: navigationAvatarSize,
                            completion: completion)
    }
    
    func updateCommentText(_ text: String) {
        commentText = text
        cacheService.update(comment: text, with: dataModel.converstionId)
    }
    
    func post() {
        let displayName = SPUserSessionHolder.session.user?.displayName ?? dataModel.displayName
        let parameters: [String: Any] = [
            CreateCommentAPIKeys.content: [[CreateCommentAPIKeys.text: commentText]],
            CreateCommentAPIKeys.metadata: [CreateCommentAPIKeys.displayName: displayName]
        ]
        
        commentService.createComment(
            parameters: parameters,
            postId: dataModel.postId,
            success: { [weak self] comment in
                Logger.verbose("FirstComment: post returned with comment \(comment)")
                guard let self = self else { return }
                
                var comment = comment
                comment.writtenAt = Date().timeIntervalSince1970
                comment.rootComment = comment.id
                let userId = SPUserSessionHolder.session.user?.id
                comment.userId = userId
                comment.depth = 0
                if let userId = comment.userId {
                    let user = SPComment.CommentUser(id: userId)
                    comment.users = [userId: user]
                }
                self.cacheService.remove(for: self.dataModel.converstionId)
                self.postCompletionHandler?(comment)
            },
            failure: { [weak self] error in
                self?.postErrorHandler?(error)
            }
        )
    }
    
    private enum CreateCommentAPIKeys {
        static let content = "content"
        static let text = "text"
        static let metadata = "metadata"
        static let displayName = "display_name"
    }
    
}
