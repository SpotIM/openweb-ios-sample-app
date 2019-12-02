//
//  SPRealTimeModel.swift
//  SpotImCore
//
//  Created by Eugene on 12.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

struct RealTimeModel: Decodable {

    let data: RealTimeDataModel?
    let nextFetch: Int
    let timestamp: Int
    
}

struct RealTimeDataModel: Decodable {
    
    enum CodingKeys: String, CodingKey {
        
        case conversationCountMessages = "conversation/count-messages"
        case conversationTypingV2Count = "conversation/typing-v2-count"
        case conversationTypingV2Users = "conversation/typing-v2-users"
        case onlineUsers = "online/users"
        
    }
    
    private let conversationCountMessages: [String: [RealTimeMessagesCountModel]]?
    private let conversationTypingV2Count: [String: [[String: Int]]]?
    private let conversationTypingV2Users: [String: [RealTimeTypingUsersModel]]?
    private let onlineUsers: [String: [RealTimeOnlineUserModel]]?
    
    /// Will return replies count in conversation if it exists and `0` if not
    func repliesCountForConversation(_ id: String) -> Int {
        return conversationCountMessages?[id]?.first?.replies ?? 0
    }
    
    /// Will return comments count in conversation if it exists and `0` if not
    func commentsCountForConversation(_ id: String) -> Int {
        return conversationCountMessages?[id]?.first?.comments ?? 0
    }
    
    /// Will return typing count in conversation if it exists and `0` if not
    func totalTypingCountForConversation(_ id: String) -> Int {
        //return conversationTypingV2Count?[id]?.first?["Overall"] ?? 0
        let count = conversationTypingV2Users?[id]?.first(where: { $0.key == "Overall" })?.count ?? 0
        return count
    }
    
    /// Will return typing count in conversation for comment if it exists and `0` if not
    func typingCountForConversation(_ id: String, commentId: String) -> Int {
        return conversationTypingV2Count?[id]?.first?[commentId] ?? 0
    }
    
    /// Will return online users array in conversation if it exists and empty array if not
    func onlineUsersForConversation(_ id: String, commentId: String) -> [RealTimeOnlineUserModel] {
        return onlineUsers?[id] ?? [RealTimeOnlineUserModel]()
    }
}

struct RealTimeMessagesCountModel: Decodable {
    
    enum CodingKeys: String, CodingKey {
        
        case replies = "Replies"
        case comments = "Comments"
        
    }
    
    let replies: Int
    let comments: Int
}

struct RealTimeOnlineUserModel: Decodable {
    
    let email: String
    let userId: String
    let displayName: String
    let userName: String
    let registered: Bool
    let imageId: String
    
}

struct RealTimeTypingUsersModel: Decodable {
    
    let users: [RealTimeOnlineUserModel]?
    let count: Int
    let key: String
    
}
