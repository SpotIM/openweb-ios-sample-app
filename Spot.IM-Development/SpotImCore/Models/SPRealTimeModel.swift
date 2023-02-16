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

internal enum RealTimeError: Error, CustomStringConvertible {
    case conversationNotFound
    case corruptedData
    case onlineViewingUsersNotFound

    var description: String {
        switch self {
        case .conversationNotFound:
            return "conversationNotFound"
        case .corruptedData:
            return "corruptedData"
        case .onlineViewingUsersNotFound:
            return "onlineUsersViewingNotFound"
        }
    }
}

struct RealTimeDataModel: Decodable {

    enum CodingKeys: String, CodingKey {
        case conversationCountMessages = "conversation/count-messages"
        case conversationTypingV2Count = "conversation/typing-v2-count"
        case conversationTypingV2Users = "conversation/typing-v2-users"
        case onlineUsers = "online/users"
        case onlineViewingUsers = "online/users-count"
        case conversationNewMessages = "conversation/new-messages"
    }

    private let conversationCountMessages: [String: [RealTimeMessagesCountModel]]?
    private let conversationTypingV2Count: [String: [[String: Int]]]?
    private let conversationTypingV2Users: [String: [RealTimeTypingUsersModel]]?
    private let onlineUsers: [String: [RealTimeOnlineUserModel]]?
    private let onlineViewingUsers: [String: [RealTimeOnlineViewingUsersModel]]?
    private let conversationNewMessages: [String: [SPComment]]?

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
            throw RealTimeError.conversationNotFound
        }

        guard let count = typingCountDataArray.first(where: { $0.key == "Overall" })?.count else {
            throw RealTimeError.corruptedData
        }

        return count
    }

    /// Will return new comments in conversation if it exists and throw conversationNotFound exception if not
    func newComments(forConversation id: String) throws -> [SPComment] {
        guard let newComments = conversationNewMessages?[id] else {
            throw RealTimeError.conversationNotFound
        }

        return newComments
    }

    /// Will return the model of viewing users if it exist and throw onlineUsersViewingNotFound exception if not
    func onlineViewingUsersCount(_ id: String) throws -> RealTimeOnlineViewingUsersModel {
        guard let onlineUsersViewingArray = onlineViewingUsers?[id],
              let onlineUsersViewing = onlineUsersViewingArray.first else {
            throw RealTimeError.onlineViewingUsersNotFound
        }

        return onlineUsersViewing
    }

    private func getRealTimeMessagesCountModel(_ id: String) throws -> RealTimeMessagesCountModel {
        guard let conversationDataArray = conversationCountMessages?[id] else {
            throw RealTimeError.conversationNotFound
        }

        guard let conversationCounterData = conversationDataArray.first else {
            throw RealTimeError.corruptedData
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

struct RealTimeOnlineViewingUsersModel: Decodable {
    let count: Int
}
