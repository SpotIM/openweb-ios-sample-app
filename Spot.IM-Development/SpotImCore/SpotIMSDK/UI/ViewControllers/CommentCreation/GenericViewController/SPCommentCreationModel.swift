//
//  SPCommentCreationModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 27/04/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation

class SPCommentCreationModel {
    
    var postCompletionHandler: ((SPComment) -> Void)?
    var errorHandler: ((Error) -> Void)?
    var commentText: String = ""
    var imageContent: SPComment.Content.Image?
    var articleMetadate: SpotImArticleMetadata
    var selectedLabels: SelectedLabels?
    var commentLabelsSection: String?
    var sectionCommentLabelsConfig: SPCommentLabelsSectionConfiguration?
    var dataModel: SPCommentCreationDTO
    
    let imageProvider: SPImageProvider
    let commentService: SPCommentUpdater
    let cacheService: SPCommentsInMemoryCacheService
    
    private var currentUploadingImageId: String?

    init(commentCreationDTO: SPCommentCreationDTO,
         cacheService: SPCommentsInMemoryCacheService,
         updater: SPCommentUpdater,
         imageProvider: SPImageProvider,
         articleMetadate: SpotImArticleMetadata
    ) {
        self.dataModel = commentCreationDTO
        self.imageProvider = imageProvider
        self.cacheService = cacheService
        commentService = updater
        self.articleMetadate = articleMetadate
        setupCommentLabels()
        
        let commentIdentifier: String = getCommentIdentifierForCommentType()
        
        if let text = commentCreationDTO.editModel?.commentText {
            commentText = text
        } else {
            commentText = cacheService.comment(for: commentIdentifier)
        }
        
        if let image = commentCreationDTO.editModel?.commentImage {
            imageContent = SPComment.Content.Image(
                originalWidth: image.width,
                originalHeight: image.height,
                imageId: image.id)
        }
    }
    
    func post() {
        
        let createCommentParameters: [String: Any] = gatherParametersForCreateCommentRequest()
        
        if self.isInEditMode() {
            handleEditCommentRequest(requestParameters: createCommentParameters)
        } else {
            handleCreateCommentRequest(requestParameters: createCommentParameters)
        }
    }
    
    func handleCreateCommentRequest(requestParameters: [String:Any]) {
        
        commentService.createComment(
            parameters: requestParameters,
            postId: dataModel.postId,
            success: {
                [weak self] response in
                guard let self = self else { return }
                
                let responseData = self.populateResponseFields(response)
                let commentIdentifier: String = self.getCommentIdentifierForCommentType()
                self.cacheService.remove(for: commentIdentifier)
                self.postCompletionHandler?(responseData)
            },
            failure: {
                [weak self] error in
                self?.errorHandler?(error)
            }
        )
    }
    
    func handleEditCommentRequest(requestParameters: [String:Any]) {
        commentService.editComment(
            parameters: requestParameters,
            postId: dataModel.postId,
            success: { [weak self] response in
                guard let self = self else { return }

                var responseData = self.populateResponseFields(response)
                responseData.setIsEdited(true)

                self.cacheService.remove(for: self.dataModel.postId)
                self.postCompletionHandler?(responseData)
            },
            failure: { [weak self] error in
                self?.errorHandler?(error)
            }
        )
    }
    
    func gatherParametersForCreateCommentRequest() -> [String: Any] {
        let displayName = SPUserSessionHolder.session.user?.displayName ?? dataModel.displayName
        
        var metadata: [String: Any] = [SPRequestKeys.displayName: displayName]
        
        var parameters: [String: Any] = [
            SPRequestKeys.content: self.getContentRequestParam()
        ]
        
        if let selectedLabels = self.selectedLabels, !selectedLabels.ids.isEmpty {
            parameters[SPRequestKeys.additionalData] = [
                SPRequestKeys.labels: [
                    SPRequestKeys.labelsSection: selectedLabels.section,
                    SPRequestKeys.labelsIds: selectedLabels.ids,
                ]
            ]
        }
        
        if isCommentAReply() {
            let commentId = dataModel.replyModel?.commentId
            let rootCommentId = dataModel.replyModel?.rootCommentId
            let isRootComment = commentId == rootCommentId
            if !isRootComment {
                metadata[SPRequestKeys.replyTo] = [SPRequestKeys.replyId: commentId]
            }
            parameters[SPRequestKeys.conversationId] = dataModel.postId
            parameters[SPRequestKeys.parentId] = rootCommentId ?? commentId
        }
        
        if let messageId = dataModel.editModel?.commentId {
            parameters[SPRequestKeys.messageId] = messageId
        }
        
        parameters[SPRequestKeys.metadata] = metadata
        
        return parameters
    }
    
    func populateResponseFields(_ response: SPComment) -> SPComment {
        var responseData = response
        responseData.writtenAt = Date().timeIntervalSince1970
        
        let userId = SPUserSessionHolder.session.user?.id
        responseData.userId = userId
        
        if let userId = responseData.userId {
            let user = SPComment.CommentUser(id: userId)
            responseData.users = [userId: user]
        }
        
        if let labels = self.selectedLabels {
            let commentLabels = SPComment.CommentLabel(section: labels.section, ids: labels.ids)
            responseData.additionalData = SPComment.AdditionalData(labels: commentLabels)
        }
        
        if self.isCommentAReply() {
            responseData.parentId = self.dataModel.replyModel?.commentId
            responseData.rootComment = self.dataModel.replyModel?.rootCommentId
            responseData.depth = (self.dataModel.replyModel?.parentDepth ?? 0) + 1
        } else {
            responseData.rootComment = responseData.id
            responseData.depth = 0
        }
        
        let commentIdentifier: String = self.getCommentIdentifierForCommentType()
        self.cacheService.remove(for: commentIdentifier)
        
        return responseData
    }
    
    func updateCommentText(_ text: String) {
        commentText = text
        let commentIdentifier: String = getCommentIdentifierForCommentType()
        cacheService.update(comment: text, with: commentIdentifier)
    }
    
    func isCommentAReply() -> Bool {
        return dataModel.replyModel != nil
    }
    
    func isInEditMode() -> Bool {
        return dataModel.editModel != nil
    }
    
    private func getCommentIdentifierForCommentType() -> String {
        if let commentIdentifier: String = dataModel.replyModel?.commentId {
            return commentIdentifier
        }
        
        return dataModel.postId
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
        imageProvider.image(from: SPUserSessionHolder.session.user?.imageURL(size: navigationAvatarSize),
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

        imageProvider.uploadImage(imageData: imageData, imageId: imageId) {
            [weak self] imageContent, err in
            guard let self = self else { return }
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
                SPRequestKeys.type: SPRequestKeys.text,
                SPRequestKeys.text: commentText
            ])
        }

        if let imageContent = self.imageContent {
            content.append([
                SPRequestKeys.type: SPRequestKeys.image,
                SPRequestKeys.imageId: imageContent.imageId,
                SPRequestKeys.originalWidth: imageContent.originalWidth,
                SPRequestKeys.originalHeight: imageContent.originalHeight
            ])
        }
        return content
    }
}
    
extension SPCommentCreationModel {
    private enum SPRequestKeys {
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
        static let messageId = "message_id"
    }
    
    struct SelectedLabels {
        var section: String
        var ids: [String]
    }
}


