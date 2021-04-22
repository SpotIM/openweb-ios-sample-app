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
    var selectedLabels: SelectedLabels? { get set }
    var articleMetadate: SpotImArticleMetadata { get set }
    
    func post()
    func updateCommentText(_ text: String)
    func updateCommentLabels(labelsIds: [String], section: String)
    func fetchNavigationAvatar(completion: @escaping ImageLoadingCompletion)
}

struct SelectedLabels {
    var section: String
    var ids: [String]
}

final class SPCommentCreationModel: CommentStateable {
    private(set) var commentText: String = ""
    var selectedLabels: SelectedLabels?
    var postCompletionHandler: ((SPComment) -> Void)?
    var postErrorHandler: ((Error) -> Void)?
    var articleMetadate: SpotImArticleMetadata
    
    let dataModel: SPCommentCreationDTO
    
    private let cacheService: SPCommentsInMemoryCacheService
    private let commentService: SPCommentUpdater
    private let imageProvider: SPImageURLProvider
    
    init(commentCreationDTO: SPCommentCreationDTO,
         cacheService: SPCommentsInMemoryCacheService,
         updater: SPCommentUpdater,
         imageProvider: SPImageURLProvider,
         articleMetadate: SpotImArticleMetadata
        ) {
        self.imageProvider = imageProvider
        self.cacheService = cacheService
        commentText = cacheService.comment(for: commentCreationDTO.converstionId)
        dataModel = commentCreationDTO
        commentService = updater
        self.articleMetadate = articleMetadate
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
    
    func updateCommentLabels(labelsIds: [String], section: String) {
        selectedLabels = SelectedLabels(section: section, ids: labelsIds)
    }
    
    func post() {
        let displayName = SPUserSessionHolder.session.user?.displayName ?? dataModel.displayName
        var parameters: [String: Any] = [
            CreateCommentAPIKeys.content: [[CreateCommentAPIKeys.text: commentText]],
            CreateCommentAPIKeys.metadata: [CreateCommentAPIKeys.displayName: displayName]
        ]
        
        if let selectedLabels = self.selectedLabels {
            parameters[CreateCommentAPIKeys.additionalData] = [
                CreateCommentAPIKeys.labels: [
                    CreateCommentAPIKeys.labelsSection: selectedLabels.section,
                    CreateCommentAPIKeys.labelsIds: selectedLabels.ids,
                ]
            ]
        }
        
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
                if let labels = self.selectedLabels {
                    let commentLabels = SPComment.CommentLabel(section: labels.section, ids: labels.ids)
                    comment.additionalData = SPComment.AdditionalData(labels: commentLabels)
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
        static let additionalData = "additional_data"
        static let labels = "labels"
        static let labelsSection = "section"
        static let labelsIds = "ids"
    }
    
}
