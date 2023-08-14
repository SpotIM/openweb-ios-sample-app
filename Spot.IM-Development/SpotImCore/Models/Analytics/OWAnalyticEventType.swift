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
    case loadMoreComments(page: Int, commentsPerPage: Int)
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
    case configureThemeEnforcement(theme: OWThemeStyle)
    case configuredInitialSort(initialSort: OWSortOption)
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
             .commentMenuEditClicked:
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
        case .loadMoreComments(let page, let commentsPerPage):
            return OWAnalyticEventPayload(payloadDictionary: [
                OWAnalyticEventPayloadKeys.page: page,
                OWAnalyticEventPayloadKeys.commentsPerPage: commentsPerPage])
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
        case .configureThemeEnforcement(let theme):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.theme: theme.rawValue])
        case .configuredInitialSort(let sort):
            return OWAnalyticEventPayload(payloadDictionary: [OWAnalyticEventPayloadKeys.initialSort: sort.rawValue])
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
    var shouldSendBI: Bool {
        return true // TODO
    }
}
