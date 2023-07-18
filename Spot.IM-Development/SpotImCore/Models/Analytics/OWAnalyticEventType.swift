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
        }
    }

    var eventGroup: OWAnalyticEventGroup {
        switch self {
        case .fullConversationLoaded,
             .preConversationLoaded,
             .loadMoreComments:
            return .loaded
        case .fullConversationViewed,
             .preConversationViewed:
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
             .signUpToPostClicked:
            return .commentCreation
        case .commentShareClicked,
             .commentReadMoreClicked,
             .commentRankUpButtonClicked,
             .commentRankDownButtonClicked,
             .commentRankUpUndoButtonClicked,
             .commentRankDownUndoButtonClicked,
             .loadMoreRepliesClicked,
             .hideMoreRepliesClicked:
            return .commentInteraction
        case .sortByClicked,
             .sortByClosed,
             .sortByChanged:
            return .sortMenu
        case .userProfileClicked,
             .myProfileClicked:
            return .profile
        }
    }

    var payload: OWAnalyticEventPayload {
        switch self {
        case .fullConversationLoaded,
             .preConversationLoaded,
             .fullConversationViewed,
             .preConversationViewed,
             .postCommentClicked,
             .signUpToPostClicked:
            return OWAnalyticEventPayload(payloadDictionary: [:])
        case .commentMenuClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: ["commentId": commentId])
        case .commentMenuClosed(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: ["commentId": commentId])
        case .commentMenuReportClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: ["commentId": commentId])
        case .commentMenuDeleteClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: ["commentId": commentId])
        case .commentMenuConfirmDeleteClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: ["commentId": commentId])
        case .commentMenuEditClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: ["commentId": commentId])
        case .editCommentClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: ["commentId": commentId])
        case .postReplyClicked(let replyToCommentId):
            return OWAnalyticEventPayload(payloadDictionary: ["replyToCommentId": replyToCommentId])
        case .commentShareClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: ["commentId": commentId])
        case .commentReadMoreClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: ["commentId": commentId])
        case .commentRankUpButtonClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: ["commentId": commentId])
        case .commentRankDownButtonClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: ["commentId": commentId])
        case .commentRankUpUndoButtonClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: ["commentId": commentId])
        case .commentRankDownUndoButtonClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: ["commentId": commentId])
        case .loadMoreComments(let page, let commentsPerPage):
            return OWAnalyticEventPayload(payloadDictionary: ["page": page, "commentsPerPage": commentsPerPage])
        case .loadMoreRepliesClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: ["commentId": commentId])
        case .hideMoreRepliesClicked(let commentId):
            return OWAnalyticEventPayload(payloadDictionary: ["commentId": commentId])
        case .sortByClicked(let currentSort):
            return OWAnalyticEventPayload(payloadDictionary: ["currentSort": currentSort.rawValue])
        case .sortByClosed(let currentSort):
            return OWAnalyticEventPayload(payloadDictionary: ["currentSort": currentSort.rawValue])
        case .sortByChanged(let previousSort, let selectedSort):
            return OWAnalyticEventPayload(payloadDictionary: ["previousSort": previousSort.rawValue, "selectedSort": selectedSort.rawValue])
        case .userProfileClicked(let userId):
            return OWAnalyticEventPayload(payloadDictionary: ["userId": userId])
        case .myProfileClicked(let source):
            return OWAnalyticEventPayload(payloadDictionary: ["source": source])
        }
    }
}
