//
//  OWCommentCreatorNetworkHelper.swift
//  SpotImCore
//
//  Created by Alon Shprung on 10/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

protocol OWCommentCreatorNetworkHelperProtocol {
    func getParametersForCreateCommentRequest(
        from commentCreationData: OWCommentCreationCtaData,
        section: String,
        commentCreationType: OWCommentCreationTypeInternal,
        postId: OWPostId
    ) -> OWNetworkParameters
}

class OWCommentCreatorNetworkHelper: OWCommentCreatorNetworkHelperProtocol {

    func getParametersForCreateCommentRequest(
        from commentCreationData: OWCommentCreationCtaData,
        section: String,
        commentCreationType: OWCommentCreationTypeInternal,
        postId: OWPostId
    ) -> OWNetworkParameters {
        var metadata: [String: Any] = [:]

        if let bundleId = Bundle.main.bundleIdentifier {
            metadata["app_bundle_id"] = bundleId
        }

        var parameters: [String: Any] = [
            "content": self.getContentRequestParam(from: commentCreationData)
        ]

        if !commentCreationData.commentLabelIds.isEmpty {
            parameters["additional_data"] = [
                "labels": [
                    "section": section,
                    "ids": commentCreationData.commentLabelIds
                ] as [String: Any]
            ]
        }

        switch commentCreationType {
        case .comment:
            break
        case .edit(let comment):
            if let messageId = comment.id {
                parameters["message_id"] = messageId
            }
        case .replyToComment(let originComment):
            let commentId = originComment.id
            let rootCommentId = originComment.rootComment
            let isRootComment = commentId == rootCommentId
            if !isRootComment {
                metadata["reply_to"] = ["reply_id": commentId]
            }
            parameters["conversation_id"] = postId
            parameters["parent_id"] = rootCommentId ?? commentId
        }

        parameters["metadata"] = metadata

        return parameters
    }
}

fileprivate extension OWCommentCreatorNetworkHelper {
    func getContentRequestParam(from commentCreationData: OWCommentCreationCtaData) -> [[String: Any]] {
        var content: [[String: Any]] = []

        if !commentCreationData.text.isEmpty {
            content.append([
                "type": "text",
                "text": commentCreationData.text
            ])
        }

        return content
    }
}
