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
    var errorHandler: ((Error) -> Void)?
    var commentText: String = ""
    var imageContent: SPComment.Content.Image?
    var articleMetadate: SpotImArticleMetadata
    var selectedLabels: SelectedLabels?
    var commentLabelsSection: String?
    var sectionCommentLabelsConfig: SPCommentLabelsSectionConfiguration?

    let imageProvider: SPImageProvider
    let commentService: SPCommentUpdater
    let cacheService: SPCommentsInMemoryCacheService

    private var currentUploadingImageId: String?

    init(cacheService: SPCommentsInMemoryCacheService,
         updater: SPCommentUpdater,
         imageProvider: SPImageProvider,
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

    func shouldDisplayImageUploadButton() -> Bool {
        if let conversationConfig = SPConfigsDataSource.appConfig?.conversation,
           conversationConfig.disableImageUploadButton == true {
            return false
        } else if !Bundle.main.hasCameraUsageDescription ||
                    !Bundle.main.hasPhotoLibraryUsageDescription {
            Logger.warn("Can't show add image button, make sure you have set NSCameraUsageDescription and NSPhotoLibraryUsageDescription in your info.plist file")
            return false
        } else {
            return true
        }
    }

    func updateCommentLabels(labelsIds: [String]) {
        if let commentLabelsSection = commentLabelsSection, !labelsIds.isEmpty {
            selectedLabels = SelectedLabels(section: commentLabelsSection, ids: labelsIds)
        } else {
            selectedLabels = nil
        }
    }

    func fetchNavigationAvatar(completion: @escaping ImageLoadingCompletion) {
        imageProvider.fetchImage(with: SPUserSessionHolder.session.user?.imageURL(size: navigationAvatarSize),
                            size: navigationAvatarSize,
                            completion: completion)
    }

    func isValidContent() -> Bool {
        return
            commentText.hasContent ||
            imageContent != nil
    }

    func uploadImageToCloudinary(imageData: String, completion: @escaping (Bool) -> Void) {
        self.imageContent = nil

        let imageId = UUID().uuidString
        self.currentUploadingImageId = imageId

        imageProvider.uploadImage(imageData: imageData, imageId: imageId) { imageContent, err in
            if self.currentUploadingImageId == imageContent?.imageId {
                self.imageContent = imageContent
                self.currentUploadingImageId = nil
                completion(imageContent != nil)
            } else if let error = err {
                print("Failed to upload image: " + error.localizedDescription)
                self.currentUploadingImageId = nil
                self.errorHandler?(error)
                completion(false)
            }
        }
    }

    func removeImage() {
        self.currentUploadingImageId = nil
        self.imageContent = nil
    }

    func getContentRequestParam() -> [[String: Any]] {
        var content: [[String: Any]] = []

        if commentText.hasContent {
            content.append([
                CreateCommentAPIKeys.type: CreateCommentAPIKeys.text,
                CreateCommentAPIKeys.text: commentText
            ])
        }

        if let imageContent = self.imageContent {
            content.append([
                CreateCommentAPIKeys.type: CreateCommentAPIKeys.image,
                CreateCommentAPIKeys.imageId: imageContent.imageId,
                CreateCommentAPIKeys.originalWidth: imageContent.originalWidth,
                CreateCommentAPIKeys.originalHeight: imageContent.originalHeight
            ])
        }
        return content
    }
}

extension SPBaseCommentCreationModel {
    internal enum CreateCommentAPIKeys {
        static let content = "content"
        static let type = "type"
        static let text = "text"
        static let image = "image"
        static let imageId = "imageId"
        static let originalHeight = "originalHeight"
        static let originalWidth = "originalWidth"
        static let metadata = "metadata"
        static let displayName = "display_name"
        static let additionalData = "additional_data"
        static let labels = "labels"
        static let labelsSection = "section"
        static let labelsIds = "ids"
        static let replyTo = "reply_to"
        static let replyId = "reply_id"
        static let parentId = "parent_id"
        static let conversationId = "conversation_id"
    }
}
