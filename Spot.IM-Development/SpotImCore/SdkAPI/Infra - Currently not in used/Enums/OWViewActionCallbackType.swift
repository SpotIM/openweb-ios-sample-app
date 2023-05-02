//
//  OWViewActionCallbackType.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWViewActionCallbackType: Codable {
    case contentPressed
    case showMoreCommentsPressed
    case writeCommentPressed
    case articleHeaderPressed
    case communityGuidelinesPressed
    case communityQuestionsPressed
    case postCommentPressed
    case adClosed
    case adTapped
    case closeConversationPressed
    case openPublisherProfile(userId: String)
}
#else
enum OWViewActionCallbackType: Codable {
    case contentPressed
    case showMoreCommentsPressed
    case writeCommentPressed
    case articleHeaderPressed
    case communityGuidelinesPressed
    case communityQuestionsPressed
    case postCommentPressed
    case adClosed
    case adTapped
    case closeConversationPressed
    case openPublisherProfile(userId: String)
}
#endif

extension OWViewActionCallbackType: Equatable {
    public static func == (lhs: OWViewActionCallbackType, rhs: OWViewActionCallbackType) -> Bool {
        switch (lhs, rhs) {
        case (.contentPressed, .contentPressed):
            return true
        case (.showMoreCommentsPressed, .showMoreCommentsPressed):
            return true
        case (.writeCommentPressed, .writeCommentPressed):
            return true
        case (.articleHeaderPressed, .articleHeaderPressed):
            return true
        case (.communityGuidelinesPressed, .communityGuidelinesPressed):
            return true
        case (.communityQuestionsPressed, .communityQuestionsPressed):
            return true
        case (.postCommentPressed, .postCommentPressed):
            return true
        case (.adClosed, .adClosed):
            return true
        case (.adTapped, .adTapped):
            return true
        case (.closeConversationPressed, .closeConversationPressed):
            return true
        case (let .openPublisherProfile(lhsId), let .openPublisherProfile(rhsId)):
            return lhsId == rhsId
        default:
            return false
        }
    }
}

