//
//  SPConversationRequests.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 16/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal enum SPConversationRequest: SPRequest {

    case conversationAsync
    case conversationRead
    case commentReport
    case commentPost
    case commentShare
    case commentUpdate
    case commentDelete
    case commentRankChange
    case commentsCounters
    case commentStatus(commentId: String)

    internal var method: OWNetworkHTTPMethod {
        switch self {
        case .conversationAsync: return .post
        case .conversationRead: return .post
        case .commentPost: return .post
        case .commentUpdate: return .patch
        case .commentDelete: return .delete
        case .commentRankChange: return .post
        case .commentReport: return .post
        case .commentShare: return .post
        case .commentsCounters: return .post
        case .commentStatus: return .get
        }
    }

    internal var pathString: String {
        switch self {
        case .conversationAsync: return "/conversation/async"
        case .conversationRead: return "/conversation/read"
        case .commentPost, .commentUpdate, .commentDelete: return "/conversation/comment"
        case .commentRankChange: return "/rank/rank/message"
        case .commentReport: return "/conversation/report/message"
        case .commentShare: return "/conversation/message/share"
        case .commentsCounters: return "/conversation/count"
        case .commentStatus(let commentId): return "/message/\(commentId)/status"
        }
    }

    internal var url: URL! {
        return URL(string: APIConstants.baseURLString + pathString)
    }
}
