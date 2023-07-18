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
        }
    }

    var eventGroup: OWAnalyticEventGroup {
        switch self {
        case .fullConversationLoaded,
             .preConversationLoaded:
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
             .postCommentClicked:
            return .commentCreation
        }
    }

    var payload: OWAnalyticEventPayload {
        switch self {
        case .fullConversationLoaded,
             .preConversationLoaded,
             .fullConversationViewed,
             .preConversationViewed,
             .postCommentClicked:
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
        }
    }
}
