//
//  OWAnalyticEvent.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 12/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

enum OWAnalyticEventType {
    case fullConversationLoaded
    case preConversationLoaded
    case fullConversationViewed
    case preConversationViewed
    case commentMenuClicked(commentId: OWCommentId)
    case commentMenuClosed(commentId: OWCommentId)
    case commentMenuReportClicked(commentId: OWCommentId)
    case commentMenuDeleteClicked(commentId: OWCommentId)
    case commentMenuConfirmDeleteClicked(commentId: OWCommentId)
    case commentMenuEditClicked(commentId: OWCommentId)
    case commentMenuMuteClicked(commentId: OWCommentId)
    case editCommentClicked(commentId: OWCommentId)
    case postCommentClicked
    case postReplyClicked(replyToCommentId: OWCommentId)
    case signUpToPostClicked
    case commentShareClicked(commentId: OWCommentId)
    case commentReadMoreClicked(commentId: OWCommentId)
    case commentRankUpButtonClicked(commentId: OWCommentId)
    case commentRankDownButtonClicked(commentId: OWCommentId)
    case commentRankUpUndoButtonClicked(commentId: OWCommentId)
    case commentRankDownUndoButtonClicked(commentId: OWCommentId)
    case loadMoreComments(paginationOffset: Int)
    case loadMoreRepliesClicked(commentId: OWCommentId)
    case hideMoreRepliesClicked(commentId: OWCommentId)
    case sortByClicked(currentSort: OWSortOption)
    case sortByClosed(currentSort: OWSortOption)
    case sortByChanged(previousSort: OWSortOption, selectedSort: OWSortOption)
    case userProfileClicked(userId: String)
    case myProfileClicked(source: OWAvatarSource)
    case createCommentCTAClicked
    case replyClicked(replyToCommentId: OWCommentId)
    case commentCreationClosePage
    case commentCreationLeavePage
    case commentCreationContinueWriting
    case loginPromptClicked
    case configuredPreConversationStyle(style: OWPreConversationStyle)
    case configuredFullConversationStyle(style: OWConversationStyle)
    case configuredCommentCreationStyle(style: OWCommentCreationStyle)
    case configuredFontFamily(font: OWFontGroupFamily)
    case configureThemeEnforcement(enforcement: OWThemeStyleEnforcement)
    case configuredInitialSort(initialSort: OWInitialSortStrategy)
    case configureSortTitle(sort: OWSortOption, title: String)
    case configureLanguageStrategy(strategy: OWLanguageStrategy)
    case localeStrategy(strategy: OWLocaleStrategy)
    case readingTime(milliseconds: Int)
    case commentViewed(commentId: OWCommentId)
    case cameraIconClickedOpen
    case cameraIconClickedTakePhoto
    case cameraIconClickedChooseFromGallery
    case cameraIconClickedClose
    case showMoreComments
}

extension OWAnalyticEventType {
    var eventName: String {
        switch self {
        case .fullConversationLoaded:
            return "fullConversationLoaded"
        case .preConversationLoaded:
            return "preConversationLoaded"
        case .fullConversationViewed:
            return "fullConversationViewed"
        case .preConversationViewed:
            return "preConversationViewed"
        case .commentMenuClicked:
            return "commentMenuClicked"
        case .commentMenuClosed:
            return "commentMenuClosed"
        case .commentMenuReportClicked:
            return "commentMenuReportClicked"
        case .commentMenuDeleteClicked:
            return "commentMenuDeleteClicked"
        case .commentMenuConfirmDeleteClicked:
            return "commentMenuConfirmDeleteClicked"
        case .commentMenuEditClicked:
            return "commentMenuEditClicked"
        case .commentMenuMuteClicked:
            return "commentMenuMuteClicked"
        case .editCommentClicked:
            return "editCommentClicked"
        case .postCommentClicked:
            return "postCommentClicked"
        case .postReplyClicked:
            return "postReplyClicked"
        case .signUpToPostClicked:
            return "signUpToPostClicked"
        case .commentShareClicked:
            return "commentShareClicked"
        case .commentReadMoreClicked:
            return "commentReadMoreClicked"
        case .commentRankUpButtonClicked:
            return "commentRankUpButtonClicked"
        case .commentRankDownButtonClicked:
            return "commentRankDownButtonClicked"
        case .commentRankUpUndoButtonClicked:
            return "commentRankUpUndoButtonClicked"
        case .commentRankDownUndoButtonClicked:
            return "commentRankDownUndoButtonClicked"
        case .loadMoreComments:
            return "loadMoreComments"
        case .loadMoreRepliesClicked:
            return "loadMoreRepliesClicked"
        case .hideMoreRepliesClicked:
            return "hideMoreRepliesClicked"
        case .sortByClicked:
            return "sortByClicked"
        case .sortByClosed:
            return "sortByClosed"
        case .sortByChanged:
            return "sortByChanged"
        case .userProfileClicked:
            return "userProfileClicked"
        case .myProfileClicked:
            return "myProfileClicked"
        case .createCommentCTAClicked:
            return "createCommentCTAClicked"
        case .replyClicked:
            return "replyClicked"
        case .commentCreationClosePage:
            return "commentCreationClosePage"
        case .commentCreationLeavePage:
            return "commentCreationLeavePage"
        case .commentCreationContinueWriting:
            return "commentCreationContinueWriting"
        case .loginPromptClicked:
            return "loginPromptClicked"
        case .configuredPreConversationStyle:
            return "configuredPreConversationStyle"
        case .configuredFullConversationStyle:
            return "configuredFullConversationStyle"
        case .configuredCommentCreationStyle:
            return "configuredCommentCreationStyle"
        case .configuredFontFamily:
            return "configuredFontFamily"
        case .configureThemeEnforcement:
            return "configureThemeEnforcement"
        case .configuredInitialSort:
            return "configuredInitialSort"
        case .configureSortTitle:
            return "configureSortTitle"
        case .configureLanguageStrategy:
            return "configureLanguageStrategy"
        case .localeStrategy:
            return "localeStrategy"
        case .readingTime:
            return "readingTime"
        case .commentViewed:
            return "commentViewed"
        case .cameraIconClickedOpen:
            return "cameraIconClickedOpen"
        case .cameraIconClickedTakePhoto:
            return "cameraIconClickedTakePhoto"
        case .cameraIconClickedChooseFromGallery:
            return "cameraIconClickedChooseFromGallery"
        case .cameraIconClickedClose:
            return "cameraIconClickedClose"
        case .showMoreComments:
            return "showMoreComments"
        }
    }

    var eventGroup: OWAnalyticEventGroup {
        switch self {
        case .fullConversationLoaded,
             .preConversationLoaded,
             .loadMoreComments:
            return .loaded
        case .fullConversationViewed,
             .preConversationViewed,
             .readingTime,
             .commentViewed:
            return .viewed
        case .commentMenuClicked,
             .commentMenuClosed,
             .commentMenuReportClicked,
             .commentMenuDeleteClicked,
             .commentMenuConfirmDeleteClicked,
             .commentMenuEditClicked,
             .commentMenuMuteClicked:
            return .commentMenu
        case .editCommentClicked,
             .postCommentClicked,
             .postReplyClicked,
             .commentCreationClosePage,
             .commentCreationLeavePage,
             .commentCreationContinueWriting,
             .createCommentCTAClicked:
            return .commentCreation
        case .cameraIconClickedOpen,
             .cameraIconClickedTakePhoto,
             .cameraIconClickedChooseFromGallery,
             .cameraIconClickedClose:
            return .camera
        case .commentReadMoreClicked,
             .loadMoreRepliesClicked,
             .hideMoreRepliesClicked,
             .replyClicked:
            return .commentInteraction
        case .commentShareClicked,
             .commentRankUpButtonClicked,
             .commentRankDownButtonClicked,
             .commentRankUpUndoButtonClicked,
             .commentRankDownUndoButtonClicked,
             .showMoreComments:
            return .engagement
        case .sortByClicked,
             .sortByClosed,
             .sortByChanged:
            return .sort
        case .userProfileClicked,
             .myProfileClicked:
            return .profile
        case .loginPromptClicked,
             .signUpToPostClicked:
            return .auth
        case .configuredPreConversationStyle,
             .configuredFullConversationStyle,
             .configuredCommentCreationStyle,
             .configuredFontFamily,
             .configureThemeEnforcement,
             .configuredInitialSort,
             .configureSortTitle,
             .configureLanguageStrategy,
             .localeStrategy:
            return .configuration
        }
    }

    var payload: OWAnalyticEventPayload {
        switch self {
        case .fullConversationLoaded,
             .preConversationLoaded,
             .fullConversationViewed,
             .preConversationViewed,
             .postCommentClicked,
             .signUpToPostClicked,
             .createCommentCTAClicked,
             .commentCreationClosePage,
             .commentCreationLeavePage,
             .commentCreationContinueWriting,
             .loginPromptClicked,
             .cameraIconClickedOpen,
             .cameraIconClickedTakePhoto,
             .cameraIconClickedChooseFromGallery,
             .cameraIconClickedClose,
             .showMoreComments:
            return OWAnalyticEventPayload(payloadDictionary: [:])
        case .commentMenuClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.commentId: commentId])
        case .commentMenuClosed(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.commentId: commentId])
        case .commentMenuReportClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.commentId: commentId])
        case .commentMenuDeleteClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.commentId: commentId])
        case .commentMenuConfirmDeleteClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.commentId: commentId])
        case .commentMenuEditClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.commentId: commentId])
        case .commentMenuMuteClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.commentId: commentId])
        case .editCommentClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.commentId: commentId])
        case .postReplyClicked(let replyToCommentId):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.replyToCommentId: replyToCommentId])
        case .commentShareClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.commentId: commentId])
        case .commentReadMoreClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.commentId: commentId])
        case .commentRankUpButtonClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.commentId: commentId])
        case .commentRankDownButtonClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.commentId: commentId])
        case .commentRankUpUndoButtonClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.commentId: commentId])
        case .commentRankDownUndoButtonClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.commentId: commentId])
        case .loadMoreComments(let paginationOffset):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.paginationOffset: paginationOffset])
        case .loadMoreRepliesClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.commentId: commentId])
        case .hideMoreRepliesClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.commentId: commentId])
        case .sortByClicked(let currentSort):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.currentSort: currentSort.rawValue])
        case .sortByClosed(let currentSort):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.currentSort: currentSort.rawValue])
        case .sortByChanged(let previousSort, let selectedSort):
            return OWAnalyticEventPayload(payloadDictionary: [
                OWAnalyticEventPayloadKeys.previousSort: previousSort.rawValue,
                OWAnalyticEventPayloadKeys.selectedSort: selectedSort.rawValue
            ])
        case .userProfileClicked(let userId):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.userId: userId])
        case .myProfileClicked(let source):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.source: source])
        case .replyClicked(let replyToCommentId):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.replyToCommentId: replyToCommentId])
        case .configuredPreConversationStyle(let style):
            return style.analyticsPayload
        case .configuredFullConversationStyle(let style):
            return style.analyticsPayload
        case .configuredCommentCreationStyle(let style):
            return style.analyticsPayload
        case .configuredFontFamily(let font):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.font: font])
        case .configureThemeEnforcement(let enforcement):
            return enforcement.analyticsPayload
        case .configuredInitialSort(let sort):
            return sort.analyticsPayload
        case .configureSortTitle(let sort, let title):
            return OWAnalyticEventPayload(payloadDictionary: [
                OWAnalyticEventPayloadKeys.sort: sort.rawValue,
                OWAnalyticEventPayloadKeys.title: title
            ])
        case .configureLanguageStrategy(let strategy):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.strategy: strategy])
        case .localeStrategy(let strategy):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.strategy: strategy])
        case .readingTime(let milliseconds):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.milliseconds: milliseconds])
        case .commentViewed(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.commentId: commentId])
        }
    }
}

// BI related
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
        case .readingTime(let milliseconds):
            return.readingTime(milliseconds: milliseconds)
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
