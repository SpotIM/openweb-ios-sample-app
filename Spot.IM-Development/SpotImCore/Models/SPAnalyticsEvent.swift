//
//  SPAnalyticsEvent.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 03/09/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal enum SPAnalyticsEvent: Equatable {
    case loaded                                     
    case viewed                                     
    case mainViewed                                 
    case messageContextMenuClicked(messageId: String, relatedMessageId: String?)
    case messageContextMenuClosed(messageId: String, relatedMessageId: String?)
    case userProfileClicked(messageId: String, userId: String, targetType: SPAnProfileTargetType)
    case myProfileClicked(messageId: String?, userId: String, targetType: SPAnProfileTargetType)
    case loginClicked(SPAnLoginTargetType)          
    case reading(Int)                               
    case loadMoreRepliesClicked(                    
        messageId: String,
        relatedMessageId: String?
    )
    case hideMoreRepliesClicked(                    
        messageId: String,
        relatedMessageId: String?
    )
    case commentReadMoreClicked(
        messageId: String,
        relatedMessageId: String?
    )
    case commentReadLessClicked(
        messageId: String,
        relatedMessageId: String?
    )
    case appInit
    case appOpened                                  
    case appClosed                                  
    case sortByOpened                               
    case sortByClicked(SPCommentSortMode)           
    case createMessageClicked(                      // ✅ ⚠️ // no message id
        itemType: SPAnItemType,
        targetType: SPAnScreenTargetType,
        relatedMessage: String?
    )
    case commentPostClicked
    case createMessageSuccessfully
    case backClicked(SPAnScreenTargetType)          // ⏳
    case loadMoreComments
    case engineStatus(SPEngineStatusType, SPEngineTargetType)
    case communityGuidelinesLinkClicked(targetUrl: String)
    case commentShareClicked(messageId: String, relatedMessageId: String?)
    case commentReportClicked(messageId: String, relatedMessageId: String?)
    case commentDeleteClicked(messageId: String, relatedMessageId: String?)
    case commentRankUpButtonClicked(messageId: String, relatedMessageId: String?)
    case commentRankDownButtonClicked(messageId: String, relatedMessageId: String?)
    case commentRankUpButtonUndo(messageId: String, relatedMessageId: String?)
    case commentRankDownButtonUndo(messageId: String, relatedMessageId: String?)
    case fullConversationAdCloseClicked
    case commentEdited(messageId: String, relatedMessageId: String?)
    case commentMuteClicked(messageId: String, relatedMessageId: String?, muteUserId: String)

    var kebabValue: String {
        switch self {
        case .loaded:
            return "loaded"
        case .viewed:
            return "viewed"
        case .mainViewed:
            return "main-viewed"
        case .messageContextMenuClicked:
            return "message-context-menu-clicked"
        case .messageContextMenuClosed:
            return "message-context-menu-closed"
        case .userProfileClicked:
            return "user-profile-clicked"
        case .myProfileClicked:
            return "my-profile-clicked"
        case .loginClicked:
            return "login-clicked"
        case .reading:
            return "reading"
        case .loadMoreRepliesClicked:
            return "load-more-replies-clicked"
        case .hideMoreRepliesClicked:
            return "hide-more-replies-clicked"
        case .commentReadMoreClicked:
            return "comment-read-more-clicked"
        case .commentReadLessClicked:
            return "comment-read-less-clicked"
        case .appInit:
            return "app-initialized"
        case .appOpened:
            return "app-opened"
        case .appClosed:
            return "app-closed"
        case .sortByOpened:
            return "sort-by-opened"
        case .sortByClicked:
            return "sort-by-clicked"
        case .createMessageClicked:
            return "create-message-clicked"
        case .commentPostClicked:
            return "comment-post-clicked"
        case .createMessageSuccessfully:
            return "create-message-successfully"
        case .backClicked:
            return "back-clicked"
        case .loadMoreComments:
            return "load-more-comments-clicked"
        case .engineStatus:
            return "engine_status"
        case .communityGuidelinesLinkClicked:
            return "community-guidelines-link-clicked"
        case .commentShareClicked:
            return "comment-share-clicked"
        case .commentReportClicked:
            return "comment-report-clicked"
        case .commentDeleteClicked:
            return "comment-delete-clicked"
        case .commentRankUpButtonClicked:
            return "comment-rank-up-button-clicked"
        case .commentRankDownButtonClicked:
            return "comment-rank-down-button-clicked"
        case .commentRankUpButtonUndo:
            return "comment-rank-up-button-undo"
        case .commentRankDownButtonUndo:
            return "comment-rank-down-button-undo"
        case .fullConversationAdCloseClicked:
            return "full-conversation-ad-close-clicked"
        case .commentEdited:
            return "comment-edited"
        case .commentMuteClicked:
            return "comment-mute-clicked"
        }
    }
    
    var eventType: SPEventType {
        switch self {
        case .loaded:
            return .loaded
        case .viewed:
            return .viewed
        case .mainViewed:
            return .mainViewed
        case .messageContextMenuClicked:
            return .messageContextMenuClicked
        case .messageContextMenuClosed:
            return .messageContextMenuClosed
        case .userProfileClicked:
            return .userProfileClicked
        case .myProfileClicked:
            return .myProfileClicked
        case .loginClicked:
            return .loginClicked
        case .reading:
            return .reading
        case .loadMoreRepliesClicked:
            return .loadMoreRepliesClicked
        case .hideMoreRepliesClicked:
            return .hideMoreRepliesClicked
        case .commentReadMoreClicked:
            return .commentReadMoreClicked
        case .commentReadLessClicked:
            return .commentReadLessClicked
        case .appInit:
            return .appInit
        case .appOpened:
            return .appOpened
        case .appClosed:
            return .appClosed
        case .sortByOpened:
            return .sortByOpened
        case .sortByClicked:
            return .sortByClicked
        case .createMessageClicked:
            return .createMessageClicked
        case .commentPostClicked:
            return .commentPostClicked
        case .createMessageSuccessfully:
            return .createMessageSuccessfully
        case .backClicked:
            return .backClicked
        case .loadMoreComments:
            return .loadMoreComments
        case .engineStatus:
            return .engineStatus
        case .communityGuidelinesLinkClicked:
            return .communityGuidelinesLinkClicked
        case .commentShareClicked:
            return .commentShareClicked
        case .commentReportClicked:
            return .commentReportClicked
        case .commentDeleteClicked:
            return .commentDeleteClicked
        case .commentRankUpButtonClicked:
            return .commentRankUpButtonClicked
        case .commentRankDownButtonClicked:
            return .commentRankDownButtonClicked
        case .commentRankUpButtonUndo:
            return .commentRankUpButtonUndo
        case .commentRankDownButtonUndo:
            return .commentRankDownButtonUndo
        case .fullConversationAdCloseClicked:
            return .fullConversationAdCloseClicked
        case .commentEdited:
            return .commentEdited
        case .commentMuteClicked:
            return .commentMuteClicked
        }
    }
    
    // is the event need to be send to our backand BI (or just for event delegate)
    var shouldSendToBI: Bool {
        switch self {
        case .loaded, .viewed, .mainViewed, .messageContextMenuClicked, .userProfileClicked, .myProfileClicked,
             .loginClicked, .reading, .loadMoreRepliesClicked, .hideMoreRepliesClicked, .appInit, .appOpened, .appClosed,
             .sortByOpened, .sortByClicked, .createMessageClicked, .backClicked, .loadMoreComments, .engineStatus, .fullConversationAdCloseClicked,
             .commentEdited, .commentMuteClicked:
            return true
        default:
            return false
        }
    }
}

internal enum SPAnSource: String {
    case launcher
    case conversation
    case mainPage

    var kebabValue: String {
        switch self {
        case .launcher:
            return "launcher-sdk"
        case .conversation:
            return "conversation-sdk"
        case .mainPage:
            return "main-page-sdk"
        }
    }
}

internal enum SPAnScreenTargetType: String {
    case preMain
    case main

    var kebabValue: String {
        switch self {
        case .preMain:
            return "pre-main"
        case .main:
            return "main"
        }
    }
}

internal enum SPAnLoginTargetType: String {
    case commentSignUp
    case mainLogin

    var kebabValue: String {
        switch self {
        case .commentSignUp:
            return "comment-sign-up"
        case .mainLogin:
            return "main-login"
        }
    }
}

internal enum SPAnProfileTargetType: String {
    case avatar
    case userName

    var kebabValue: String {
        switch self {
        case .avatar:
            return "profile-avatar"
        case .userName:
            return "profile-user-name"
        }
    }
}

internal enum SPAnItemType: String, SPKebabable {
    case login
    case main
    case comment
    case reply

    var kebabValue: String {
        switch self {
        case .login:
            return "login"
        case .main:
            return "main"
        case .comment:
            return "comment"
        case .reply:
            return "reply"
        }
    }
}

internal enum SPEngineStatusType: String, SPKebabable {
    case engineMonitizationLoad
    case engineWillInitialize
    case engineInitialized
    case engineInitilizeFailed
    case engineMonetizationView
    
    var kebabValue: String {
        switch self {
        case .engineMonitizationLoad:
            return "engine-monetization-load"
        case .engineWillInitialize:
            return "engine-will-initialize"
        case .engineInitialized:
            return "engine-initialized"
        case .engineInitilizeFailed:
            return "engine-initialize-error"
        case .engineMonetizationView:
            return "engine-monetization-view"
        }
    }
}

internal enum SPEngineTargetType: String {
    case banner
    case interstitial

    var kebabValue: String {
        switch self {
        case .banner:
            return "banner"
        case .interstitial:
            return "interstitial"
        }
    }
}

internal protocol SPKebabable {
    // TODO: (Fedin) Make a default implementation that computes kebabValue from rawValue
    var kebabValue: String { get }
}
