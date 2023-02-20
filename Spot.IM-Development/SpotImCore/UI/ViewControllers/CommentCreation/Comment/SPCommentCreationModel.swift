//
//  SPCommentCreationModel.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/1/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

protocol CommentStateable {

    func post()
    func updateCommentText(_ text: String)
    func updateCommentLabels(labelsIds: [String])
    func fetchNavigationAvatar(completion: @escaping ImageLoadingCompletion)
}

struct SelectedLabels {
    var section: String
    var ids: [String]
}

final class SPCommentCreationModel: SPBaseCommentCreationModel {

    var dataModel: SPCommentCreationDTO

    init(commentCreationDTO: SPCommentCreationDTO,
         cacheService: SPCommentsInMemoryCacheService,
         updater: SPCommentUpdater,
         imageProvider: SPImageProvider,
         articleMetadate: SpotImArticleMetadata
        ) {
        self.dataModel = commentCreationDTO
        super.init(cacheService: cacheService, updater: updater, imageProvider: imageProvider, articleMetadate: articleMetadate)
        commentText = cacheService.comment(for: commentCreationDTO.converstionId)
    }

    override func updateCommentText(_ text: String) {
        commentText = text
        cacheService.update(comment: text, with: dataModel.converstionId)
    }

    override func post() {
        let displayName = SPUserSessionHolder.session.user?.displayName ?? dataModel.displayName
        var parameters: [String: Any] = [
            CreateCommentAPIKeys.content: self.getContentRequestParam(),
            CreateCommentAPIKeys.metadata: [CreateCommentAPIKeys.displayName: displayName]
        ]

        if let selectedLabels = self.selectedLabels, !selectedLabels.ids.isEmpty {
            parameters[CreateCommentAPIKeys.additionalData] = [
                CreateCommentAPIKeys.labels: [
                    CreateCommentAPIKeys.labelsSection: selectedLabels.section,
                    CreateCommentAPIKeys.labelsIds: selectedLabels.ids
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
                self?.errorHandler?(error)
            }
        )
    }
}
