//
//  OWBIAnalyticEvent.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 14/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWBIAnalyticEvent {
    case fullConversationLoaded
    case preConversationLoaded
    case fullConversationViewed
    case preConversationViewed
    case commentMenuClicked(commentId: String)
    case commentMenuClosed(commentId: String)
    case commentMenuReportClicked(commentId: String)
    case commentMenuDeleteClicked(commentId: String)
    case commentMenuConfirmDeleteClicked(commentId: String)
    case commentMenuEditClicked(commentId: String)
    case commentMenuMuteClicked(commentId: String)
    case editCommentClicked(commentId: String)
    case postCommentClicked
    case postReplyClicked(replyToCommentId: String)
    case signUpToPostClicked
    case commentShareClicked(commentId: String)
    case commentReadMoreClicked(commentId: String)
    case commentRankUpButtonClicked(commentId: String)
    case commentRankDownButtonClicked(commentId: String)
    case commentRankUpUndoButtonClicked(commentId: String)
    case commentRankDownUndoButtonClicked(commentId: String)
    case loadMoreRepliesClicked(commentId: String)
    case hideMoreRepliesClicked(commentId: String)
    case sortByClicked(currentSort: OWSortOption)
    case sortByClosed(currentSort: OWSortOption)
    case sortByChanged(previousSort: OWSortOption, selectedSort: OWSortOption)
    case userProfileClicked
    case myProfileClicked(source: String)
    case createCommentCTAClicked
    case replyClicked(replyToCommentId: String)
    case commentCreationClosePage
    case commentCreationLeavePage
    case commentCreationContinueWriting
    case loginPromptClicked
    case commentViewed(commentId: String)
    case cameraIconClickedOpen
    case cameraIconClickedTakePhoto
    case cameraIconClickedChooseFromGallery
    case cameraIconClickedClose
    case showMoreComments
}

#else
enum OWBIAnalyticEvent {
    case fullConversationLoaded
    case preConversationLoaded
    case fullConversationViewed
    case preConversationViewed
    case commentMenuClicked(commentId: String)
    case commentMenuClosed(commentId: String)
    case commentMenuReportClicked(commentId: String)
    case commentMenuDeleteClicked(commentId: String)
    case commentMenuConfirmDeleteClicked(commentId: String)
    case commentMenuEditClicked(commentId: String)
    case commentMenuMuteClicked(commentId: String)
    case editCommentClicked(commentId: String)
    case postCommentClicked
    case postReplyClicked(replyToCommentId: String)
    case signUpToPostClicked
    case commentShareClicked(commentId: String)
    case commentReadMoreClicked(commentId: String)
    case commentRankUpButtonClicked(commentId: String)
    case commentRankDownButtonClicked(commentId: String)
    case commentRankUpUndoButtonClicked(commentId: String)
    case commentRankDownUndoButtonClicked(commentId: String)
    case loadMoreRepliesClicked(commentId: String)
    case hideMoreRepliesClicked(commentId: String)
    case sortByClicked(currentSort: OWSortOption)
    case sortByClosed(currentSort: OWSortOption)
    case sortByChanged(previousSort: OWSortOption, selectedSort: OWSortOption)
    case userProfileClicked
    case myProfileClicked(source: String)
    case createCommentCTAClicked
    case replyClicked(replyToCommentId: String)
    case commentCreationClosePage
    case commentCreationLeavePage
    case commentCreationContinueWriting
    case loginPromptClicked
    case commentViewed(commentId: String)
    case cameraIconClickedOpen
    case cameraIconClickedTakePhoto
    case cameraIconClickedChooseFromGallery
    case cameraIconClickedClose
    case showMoreComments
}
#endif
