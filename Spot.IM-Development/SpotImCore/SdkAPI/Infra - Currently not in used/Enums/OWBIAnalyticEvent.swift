//
//  OWBIAnalyticEvent.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 14/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

// TODO: init with eventType
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
    case readingTime(milliseconds: Int)
    case commentViewed(commentId: String)
    case cameraIconClickedOpen
    case cameraIconClickedTakePhoto
    case cameraIconClickedChooseFromGallery
    case cameraIconClickedClose
    case showMoreComments

    init(event: OWAnalyticEventType) {
        switch event {
        case .fullConversationLoaded:
            self = .fullConversationLoaded
        case .preConversationLoaded:
            self = .preConversationLoaded
        case .fullConversationViewed:
            self = .fullConversationViewed
        case .preConversationViewed:
            self = .preConversationViewed
        case .commentMenuClicked(let commentId):
            self = .commentMenuClicked(commentId: commentId)
        case .commentMenuClosed(let commentId):
            self = .commentMenuClosed(commentId: commentId)
        case .commentMenuReportClicked(let commentId):
            self = .commentMenuReportClicked(commentId: commentId)
        case .commentMenuDeleteClicked(let commentId):
            self = .commentMenuDeleteClicked(commentId: commentId)
        case .commentMenuConfirmDeleteClicked(let commentId):
            self = .commentMenuConfirmDeleteClicked(commentId: commentId)
        case .commentMenuEditClicked(let commentId):
            self = .commentMenuEditClicked(commentId: commentId)
//        case .commentMenuMuteClicked(let commentId):
//            self = .commentMenuMuteClicked(commentId: commentId)
        case .editCommentClicked(let commentId):
            self = .editCommentClicked(commentId: commentId)
        case .postCommentClicked:
            self = .postCommentClicked
        case .postReplyClicked(let replyToCommentId):
            self = .postReplyClicked(replyToCommentId: replyToCommentId)
        case .signUpToPostClicked:
            self = .signUpToPostClicked
        case .commentShareClicked(let commentId):
            self = .commentShareClicked(commentId: commentId)
        case .commentReadMoreClicked(let commentId):
            self = .commentReadMoreClicked(commentId: commentId)
        case .commentRankUpButtonClicked(let commentId):
            self = .commentRankUpButtonClicked(commentId: commentId)
        case .commentRankDownButtonClicked(let commentId):
            self = .commentRankDownButtonClicked(commentId: commentId)
        case .commentRankUpUndoButtonClicked(let commentId):
            self = .commentRankUpUndoButtonClicked(commentId: commentId)
        case .commentRankDownUndoButtonClicked(let commentId):
            self = .commentRankDownUndoButtonClicked(commentId: commentId)
//        case .loadMoreComments(let paginationOffset):
//            <#code#>
        case .loadMoreRepliesClicked(let commentId):
            self = .loadMoreRepliesClicked(commentId: commentId)
        case .hideMoreRepliesClicked(let commentId):
            self = .hideMoreRepliesClicked(commentId: commentId)
        case .sortByClicked(let currentSort):
            self = .sortByClicked(currentSort: currentSort)
        case .sortByClosed(let currentSort):
            self = .sortByClosed(currentSort: currentSort)
        case .sortByChanged(let previousSort, let selectedSort):
            self = .sortByChanged(previousSort: previousSort, selectedSort: selectedSort)
        case .userProfileClicked:
            self = .userProfileClicked
        case .myProfileClicked(let source):
            self = .myProfileClicked(source: source.rawValue)
        case .createCommentCTAClicked:
            self = .createCommentCTAClicked
        case .replyClicked(let replyToCommentId):
            self = .replyClicked(replyToCommentId: replyToCommentId)
        case .commentCreationClosePage:
            self = .commentCreationClosePage
        case .commentCreationLeavePage:
            self = .commentCreationLeavePage
        case .commentCreationContinueWriting:
            self = .commentCreationContinueWriting
        case .loginPromptClicked:
            self = .loginPromptClicked
//        case .configuredPreConversationStyle(let style):
//            <#code#>
//        case .configuredFullConversationStyle(let style):
//            <#code#>
//        case .configuredCommentCreationStyle(let style):
//            <#code#>
//        case .configuredFontFamily(let font):
//            <#code#>
//        case .configureThemeEnforcement(let enforcement):
//            <#code#>
//        case .configuredInitialSort(let initialSort):
//            <#code#>
//        case .configureSortTitle(let sort, let title):
//            <#code#>
//        case .configureLanguageStrategy(let strategy):
//            <#code#>
//        case .localeStrategy(let strategy):
//            <#code#>
        case .readingTime(let milliseconds):
            self = .readingTime(milliseconds: milliseconds)
        case .commentViewed(let commentId):
            self = .commentViewed(commentId: commentId)
        case .cameraIconClickedOpen:
            self = .cameraIconClickedOpen
        case .cameraIconClickedTakePhoto:
            self = .cameraIconClickedTakePhoto
        case .cameraIconClickedChooseFromGallery:
            self = .cameraIconClickedChooseFromGallery
        case .cameraIconClickedClose:
            self = .cameraIconClickedClose
        case .showMoreComments:
            self = .showMoreComments
        default:
        }
    }
}

#else
enum OWBIAnalyticEvent {
    case a
}
#endif
