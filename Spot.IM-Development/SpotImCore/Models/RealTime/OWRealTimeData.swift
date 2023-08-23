//
//  OWRealTimeData.swift
//  SpotImCore
//
//  Created by Revital Pisman on 06/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift
import RxCocoa

struct OWRealTimeData: Decodable {
    private let conversationCountMessages: [String: [OWRealTimeMessagesCount]]?
    private let conversationTypingV2Count: [String: [[String: Int]]]?
    private let conversationTypingV2Users: [String: [OWRealTimeTypingUsers]]?
    private let onlineViewingUsers: [String: [OWRealTimeOnlineViewingUsers]]?
    private let conversationNewMessages: [String: [OWComment]]?

    enum CodingKeys: String, CodingKey {
        case conversationCountMessages = "conversation/count-messages"
        case conversationTypingV2Count = "conversation/typing-v2-count"
        case conversationTypingV2Users = "conversation/typing-v2-users"
        case onlineUsers = "online/users"
        case onlineViewingUsers = "online/users-count"
        case conversationNewMessages = "conversation/new-messages"
    }

    let onlineUsers: [String: [OWRealTimeOnlineUser]]?

    func totalCommentsCount(forConversation id: String) throws -> Int {
        let commentsCounter = try commentsCount(forConversation: id)
        let repliesCounter = try repliesCount(forConversation: id)
        return commentsCounter + repliesCounter
    }

    func repliesCount(forConversation id: String) throws -> Int {
        let conversationCounterData = try getMessagesCountModel(forConversation: id)
        return conversationCounterData.replies
    }

    func commentsCount(forConversation id: String) throws -> Int {
        let conversationCounterData = try getMessagesCountModel(forConversation: id)
        return conversationCounterData.comments
    }

    // Typing count method
    func totalTypingCount(forConversation id: String) throws -> Int {
        guard let typingCountDataArray = conversationTypingV2Users?[id],
              let count = typingCountDataArray.first(where: { $0.key == "Overall" })?.count else {
            throw RealTimeError.conversationNotFound
        }
        return count
    }

    // New comments method
    func newComments(forConversation id: String) throws -> [OWComment] {
        guard let newComments = conversationNewMessages?[id] else {
            throw RealTimeError.conversationNotFound
        }
        return newComments
    }

    // Online viewing users method
    func onlineViewingUsersCount(_ id: String) throws -> OWRealTimeOnlineViewingUsers {
        guard let onlineUsersViewingArray = onlineViewingUsers?[id],
              let onlineUsersViewing = onlineUsersViewingArray.first else {
            throw RealTimeError.onlineViewingUsersNotFound
        }
        return onlineUsersViewing
    }

    // Private method to fetch messages count model
    private func getMessagesCountModel(forConversation id: String) throws -> OWRealTimeMessagesCount {
        guard let conversationDataArray = conversationCountMessages?[id],
              let conversationCounterData = conversationDataArray.first else {
            throw RealTimeError.conversationNotFound
        }
        return conversationCounterData
    }
}
