//
//  SPBaseCommentCreationModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 27/04/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation

class SPBaseCommentCreationModel: CommentStateable {
    
    var postCompletionHandler: ((SPComment) -> Void)?
    var postErrorHandler: ((Error) -> Void)?
    var commentText: String = ""
    var articleMetadate: SpotImArticleMetadata
    var selectedLabels: SelectedLabels?
    var commentLabelsSection: String?
    var sectionCommentLabelsConfig: SPCommentLabelsSectionConfiguration?
    var dataModel: SPBaseCommentCreationDTO
    
    let imageProvider: SPImageURLProvider
    let commentService: SPCommentUpdater
    let cacheService: SPCommentsInMemoryCacheService
    
    init(baseCommentCreationDTO: SPBaseCommentCreationDTO,
         cacheService: SPCommentsInMemoryCacheService,
         updater: SPCommentUpdater,
         imageProvider: SPImageURLProvider,
         articleMetadate: SpotImArticleMetadata
    ) {
        self.dataModel = baseCommentCreationDTO
        self.imageProvider = imageProvider
        self.cacheService = cacheService
        commentService = updater
        self.articleMetadate = articleMetadate
        setupCommentLabels()
        
        let commentIdentifier: String = getCommentIdentifierForCommentType()
        commentText = cacheService.comment(for: commentIdentifier)
        
    }
    
    func post() {
        
    }
    
    func updateCommentText(_ text: String) {
        commentText = text
        if let commentIdentifier : String = self.dataModel.replyModel?.commentId {
            cacheService.update(comment: text, with: commentIdentifier)
        } else {
            cacheService.update(comment: text, with: self.dataModel.postId)
        }
    }
    
    private func getCommentIdentifierForCommentType() -> String {
        if let commentIdentifier : String = self.dataModel.replyModel?.commentId {
            return commentIdentifier
        }
        
        return self.dataModel.postId
    }

    private func setupCommentLabels() {
        guard let sharedConfig = SPConfigsDataSource.appConfig?.shared,
              sharedConfig.enableCommentLabels == true,
              let commentLabelsConfig = sharedConfig.commentLabels else { return }
        (sectionCommentLabelsConfig, commentLabelsSection) = getLabelsSectionConfig(commentLabelsConfig: commentLabelsConfig)
    }
    
    private func getLabelsSectionConfig(commentLabelsConfig: Dictionary<String, SPCommentLabelsSectionConfiguration>) -> (SPCommentLabelsSectionConfiguration?, String?) {
        var sectionLabelsConfig: SPCommentLabelsSectionConfiguration? = nil
        var commentLabelsSection: String? = nil
        // here we want to match the article section to the commentLabelsConfig section (if exists) - if not, we will take the default.
        if commentLabelsConfig[articleMetadate.section] != nil {
            sectionLabelsConfig = commentLabelsConfig[articleMetadate.section]
            commentLabelsSection = articleMetadate.section
        } else if commentLabelsConfig["default"] != nil {
            sectionLabelsConfig = commentLabelsConfig["default"]
            commentLabelsSection = "default"
        }
        return (sectionLabelsConfig, commentLabelsSection)
    }
    
    func updateCommentLabels(labelsIds: [String]) {
        if let commentLabelsSection = commentLabelsSection, !labelsIds.isEmpty {
            selectedLabels = SelectedLabels(section: commentLabelsSection, ids: labelsIds)
        } else {
            selectedLabels = nil
        }
    }
    
    func fetchNavigationAvatar(completion: @escaping ImageLoadingCompletion) {
        imageProvider.image(with: SPUserSessionHolder.session.user?.imageURL(size: navigationAvatarSize),
                            size: navigationAvatarSize,
                            completion: completion)
    }
}
