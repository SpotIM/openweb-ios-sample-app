//
//  SPReplyCreationModel.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/7/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

final class SPReplyCreationModel: SPBaseCommentCreationModel {

    var dataModel: SPReplyCreationDTO

    init(replyCreationDTO: SPReplyCreationDTO,
         cacheService: SPCommentsInMemoryCacheService,
         updater: SPCommentUpdater,
         imageProvider: SPImageProvider,
         articleMetadata: SpotImArticleMetadata
        ) {
        self.dataModel = replyCreationDTO
        super.init(cacheService: cacheService, updater: updater, imageProvider: imageProvider, articleMetadate: articleMetadata)
        commentText = cacheService.comment(for: replyCreationDTO.commentId)
    }

    override func updateCommentText(_ text: String) {
        commentText = text
        cacheService.update(comment: text, with: dataModel.commentId)
    }

    override func post() {

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
                if let labels = self.selectedLabels {
                    let commentLabels = SPComment.CommentLabel(section: labels.section, ids: labels.ids)
                    reply.additionalData = SPComment.AdditionalData(labels: commentLabels)
                }
                self.cacheService.remove(for: self.dataModel.commentId)
                self.postCompletionHandler?(reply)
            },
            failure: { [weak self] error in
                self?.errorHandler?(error)
            }
        )
    }

    private func postParameters() -> [String: Any] {

        let userId = SPUserSessionHolder.session.user?.displayName ?? dataModel.displayName

        var metadata: [String: Any] = [
            CreateCommentAPIKeys.displayName: userId
        ]

        let isRootComment = dataModel.commentId == dataModel.rootCommentId
        if !isRootComment {
            metadata[CreateCommentAPIKeys.replyTo] = [CreateCommentAPIKeys.replyId: dataModel.commentId]
        }

        var parameters = [
            CreateCommentAPIKeys.parentId: dataModel.rootCommentId ?? dataModel.commentId,
            CreateCommentAPIKeys.conversationId: dataModel.postId,
            CreateCommentAPIKeys.content: self.getContentRequestParam(),
            CreateCommentAPIKeys.metadata: metadata
        ] as [String: Any]

        if let selectedLabels = self.selectedLabels {
            parameters[CreateCommentAPIKeys.additionalData] = [
                CreateCommentAPIKeys.labels: [
                    CreateCommentAPIKeys.labelsSection: selectedLabels.section,
                    CreateCommentAPIKeys.labelsIds: selectedLabels.ids
                ]
            ]
        }

        return parameters
    }
}
