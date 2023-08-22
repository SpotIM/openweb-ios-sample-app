//
//  OWAnalyticEventType+BIExtensions.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 21/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

extension OWAnalyticEventType {
    // We only want to send some event to the publisher. For unwanted events we will return nil
    var biAnalyticEvent: OWBIAnalyticEvent? {
        switch self {
        case .fullConversationLoaded:
            return.fullConversationLoaded
        case .preConversationLoaded:
            return.preConversationLoaded
        case .fullConversationViewed:
            return.fullConversationViewed
        case .preConversationViewed:
            return.preConversationViewed
        case .commentMenuClicked(let commentId):
            return.commentMenuClicked(commentId: commentId)
        case .commentMenuClosed(let commentId):
            return.commentMenuClosed(commentId: commentId)
        case .commentMenuReportClicked(let commentId):
            return.commentMenuReportClicked(commentId: commentId)
        case .commentMenuDeleteClicked(let commentId):
            return.commentMenuDeleteClicked(commentId: commentId)
        case .commentMenuConfirmDeleteClicked(let commentId):
            return.commentMenuConfirmDeleteClicked(commentId: commentId)
        case .commentMenuEditClicked(let commentId):
            return.commentMenuEditClicked(commentId: commentId)
        case .commentMenuMuteClicked(let commentId):
            return.commentMenuMuteClicked(commentId: commentId)
        case .editCommentClicked(let commentId):
            return.editCommentClicked(commentId: commentId)
        case .postCommentClicked:
            return.postCommentClicked
        case .postReplyClicked(let replyToCommentId):
            return.postReplyClicked(replyToCommentId: replyToCommentId)
        case .signUpToPostClicked:
            return.signUpToPostClicked
        case .commentShareClicked(let commentId):
            return.commentShareClicked(commentId: commentId)
        case .commentReadMoreClicked(let commentId):
            return.commentReadMoreClicked(commentId: commentId)
        case .commentRankUpButtonClicked(let commentId):
            return.commentRankUpButtonClicked(commentId: commentId)
        case .commentRankDownButtonClicked(let commentId):
            return.commentRankDownButtonClicked(commentId: commentId)
        case .commentRankUpUndoButtonClicked(let commentId):
            return.commentRankUpUndoButtonClicked(commentId: commentId)
        case .commentRankDownUndoButtonClicked(let commentId):
            return.commentRankDownUndoButtonClicked(commentId: commentId)
        case .loadMoreRepliesClicked(let commentId):
            return.loadMoreRepliesClicked(commentId: commentId)
        case .hideMoreRepliesClicked(let commentId):
            return.hideMoreRepliesClicked(commentId: commentId)
        case .sortByClicked(let currentSort):
            return.sortByClicked(currentSort: currentSort)
        case .sortByClosed(let currentSort):
            return.sortByClosed(currentSort: currentSort)
        case .sortByChanged(let previousSort, let selectedSort):
            return.sortByChanged(previousSort: previousSort, selectedSort: selectedSort)
        case .userProfileClicked:
            return.userProfileClicked
        case .myProfileClicked(let source):
            return.myProfileClicked(source: source.rawValue)
        case .createCommentCTAClicked:
            return.createCommentCTAClicked
        case .replyClicked(let replyToCommentId):
            return.replyClicked(replyToCommentId: replyToCommentId)
        case .commentCreationClosePage:
            return.commentCreationClosePage
        case .commentCreationLeavePage:
            return.commentCreationLeavePage
        case .commentCreationContinueWriting:
            return.commentCreationContinueWriting
        case .loginPromptClicked:
            return.loginPromptClicked
        case .commentViewed(let commentId):
            return.commentViewed(commentId: commentId)
        case .cameraIconClickedOpen:
            return.cameraIconClickedOpen
        case .cameraIconClickedTakePhoto:
            return.cameraIconClickedTakePhoto
        case .cameraIconClickedChooseFromGallery:
            return.cameraIconClickedChooseFromGallery
        case .cameraIconClickedClose:
            return.cameraIconClickedClose
        case .showMoreComments:
            return.showMoreComments
        default:
            return nil
        }
    }
}
