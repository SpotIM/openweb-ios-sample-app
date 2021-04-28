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
    
    let imageProvider: SPImageURLProvider
    let commentService: SPCommentUpdater
    let cacheService: SPCommentsInMemoryCacheService
    
    init(cacheService: SPCommentsInMemoryCacheService,
         updater: SPCommentUpdater,
         imageProvider: SPImageURLProvider,
         articleMetadate: SpotImArticleMetadata
    ) {
        self.imageProvider = imageProvider
        self.cacheService = cacheService
        commentService = updater
        self.articleMetadate = articleMetadate
        self.setupCommentLabels()
    }
    
    func post() {}
    func updateCommentText(_ text: String) {}
    func fetchNavigationAvatar(completion: @escaping ImageLoadingCompletion) {}

    private func setupCommentLabels() {
        guard let sharedConfig = SPConfigsDataSource.appConfig?.shared,
              sharedConfig.enableCommentLabels == true,
              let commentLabelsConfig = sharedConfig.commentLabels else { return }
        sectionCommentLabelsConfig = getLabelsSectionConfig(commentLabelsConfig: commentLabelsConfig)
    }
    
    private func getLabelsSectionConfig(commentLabelsConfig: Dictionary<String, SPCommentLabelsSectionConfiguration>) -> SPCommentLabelsSectionConfiguration? {
        var sectionLabelsConfig: SPCommentLabelsSectionConfiguration? = nil
        if commentLabelsConfig[articleMetadate.section] != nil {
            sectionLabelsConfig = commentLabelsConfig[articleMetadate.section]
            commentLabelsSection = articleMetadate.section
        } else if commentLabelsConfig["default"] != nil {
            sectionLabelsConfig = commentLabelsConfig["default"]
            commentLabelsSection = "default"
        }
        return sectionLabelsConfig
    }
    
    func updateCommentLabels(labelsIds: [String]) {
        if let commentLabelsSection = commentLabelsSection, !labelsIds.isEmpty {
            selectedLabels = SelectedLabels(section: commentLabelsSection, ids: labelsIds)
        } else {
            selectedLabels = nil
        }
    }
}
