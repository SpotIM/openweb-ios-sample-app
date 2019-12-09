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
    case messageContextMenuClicked(String)          
    case userProfileClicked(                        
        messageId: String,
        userId: String
    )
    case myProfileClicked(messageId: String, userId: String)
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
    case appOpened                                  
    case appClosed                                  
    case sortByOpened                               
    case sortByClicked(SPCommentSortMode)           
    case createMessageClicked(                      // ✅ ⚠️ // no message id
        itemType: SPAnItemType,
        targetType: SPAnScreenTargetType,
        relatedMessage: String?
    )
    case backClicked(SPAnScreenTargetType)          // ⏳
    case deleteMessage
    case shareMessage
    case loadMoreComments

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
        case .backClicked:
            return "back-clicked"
        case .deleteMessage:
            return "delete-message-clicked"
        case .shareMessage:
            return "share-message-clicked"
        case .loadMoreComments:
            return "load-more-comments-clicked"
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
            return "launcher"
        case .conversation:
            return "conversation"
        case .mainPage:
            return "main-page"
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

internal protocol SPKebabable {
    // TODO: (Fedin) Make a default implementation that computes kebabValue from rawValue
    var kebabValue: String { get }
}
