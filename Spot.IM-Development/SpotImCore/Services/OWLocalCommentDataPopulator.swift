//
//  OWLocalCommentDataPopulator.swift
//  SpotImCore
//
//  Created by Alon Shprung on 02/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

protocol OWLocalCommentDataPopulating {
    func populate(commentResponse: OWComment, with additionalData: OWComment.AdditionalData?, user: SPUser, commentCreationType: OWCommentCreationTypeInternal) -> OWComment
}

class OWLocalCommentDataPopulator: OWLocalCommentDataPopulating {
    func populate(commentResponse: OWComment, with additionalData: OWComment.AdditionalData?, user: SPUser, commentCreationType: OWCommentCreationTypeInternal) -> OWComment {
        var updatedComment = commentResponse
        updatedComment.writtenAt = Date().timeIntervalSince1970

        updatedComment.userId = user.id

        if let userId = updatedComment.userId {
            updatedComment.users = [userId: user]
        }

        if let additionalData = additionalData {
            updatedComment.additionalData = additionalData
        }

        switch commentCreationType {
        case .replyToComment(let originComment):
            updatedComment.parentId = originComment.id
            updatedComment.rootComment = originComment.rootComment
            updatedComment.depth = (originComment.depth ?? 0) + 1
        case .edit(let originComment):
            updatedComment.parentId = originComment.parentId
            updatedComment.rootComment = originComment.rootComment
            updatedComment.depth = originComment.depth
            updatedComment.repliesCount = originComment.repliesCount
            updatedComment.totalRepliesCount = originComment.totalRepliesCount
            updatedComment.offset = originComment.offset
            updatedComment.setIsEdited(true)
        case .comment:
            updatedComment.rootComment = updatedComment.id
            updatedComment.depth = 0
        }

        return updatedComment
    }
}
