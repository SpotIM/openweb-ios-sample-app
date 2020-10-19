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

internal enum RealTimeErorr: Error, CustomStringConvertible {
    case conversationNotFound
    case corruptedData
    
    var description: String {
        switch self {
        case .conversationNotFound:
            return "conversationNotFound"
        case .corruptedData:
            return "corruptedData"
        }
    }
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
    
    func totalCommentsCountForConversation(_ id: String) throws -> Int {
        let commentsCounter = try commentsCountForConversation(id)
        let repliesCounter = try repliesCountForConversation(id)
        
        return commentsCounter + repliesCounter
    }
    
    /// Will return replies count in conversation if it exists and throw conversationNotFound exception if not
    func repliesCountForConversation(_ id: String) throws -> Int {
        let conversationCounterData = try self.getRealTimeMessagesCountModel(id)
        
        return conversationCounterData.replies
    }
    
    /// Will return comments count in conversation if it exists and throw conversationNotFound exception if not
    func commentsCountForConversation(_ id: String) throws -> Int {
        let conversationCounterData = try self.getRealTimeMessagesCountModel(id)
        
        return conversationCounterData.comments
    }
    
    /// Will return typing count in conversation if it exists and throw conversationNotFound exception if not
    func totalTypingCountForConversation(_ id: String) throws -> Int {
        guard let typingCountDataArray = conversationTypingV2Users?[id] else {
            throw RealTimeErorr.conversationNotFound
        }
        
        guard let count = typingCountDataArray.first(where: { $0.key == "Overall" })?.count else {
            throw RealTimeErorr.corruptedData
        }
        
        return count
    }
    
    private func getRealTimeMessagesCountModel(_ id: String) throws -> RealTimeMessagesCountModel {
        guard let conversationDataArray = conversationCountMessages?[id] else {
            throw RealTimeErorr.conversationNotFound
        }
        
        guard let conversationCounterData = conversationDataArray.first else {
            throw RealTimeErorr.corruptedData
        }
        
        return conversationCounterData
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
