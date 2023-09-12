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
    fileprivate let conversationCountMessages: [String: [OWRealTimeMessagesCount]]
    fileprivate let conversationTypingV2Count: [String: [[String: Int]]]
    fileprivate let conversationTypingV2Users: [String: [OWRealTimeTypingUsers]]
    fileprivate let conversationNewMessages: [String: [OWComment]]
    fileprivate let onlineViewingUsers: [String: [OWRealTimeOnlineViewingUsers]]
    fileprivate let onlineUsers: [String: [OWRealTimeOnlineUser]]

    enum CodingKeys: String, CodingKey {
        case conversationCountMessages = "conversation/count-messages"
        case conversationTypingV2Count = "conversation/typing-v2-count"
        case conversationTypingV2Users = "conversation/typing-v2-users"
        case conversationNewMessages = "conversation/new-messages"
        case onlineViewingUsers = "online/users-count"
        case onlineUsers = "online/users"
    }

    struct Metrics {
        static let typingCountKey = "Overall"
        static let defaultRealTimeOnlineViewingUsers = OWRealTimeOnlineViewingUsers(count: 1)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // If data is missing or invalid, provided default values [:]
        self.conversationCountMessages = (try? container.decodeIfPresent([String: [OWRealTimeMessagesCount]].self, forKey: .conversationCountMessages)) ?? [:]
        self.conversationTypingV2Count = (try? container.decodeIfPresent([String: [[String: Int]]].self, forKey: .conversationTypingV2Count)) ?? [:]
        self.conversationTypingV2Users = (try? container.decodeIfPresent([String: [OWRealTimeTypingUsers]].self, forKey: .conversationTypingV2Users)) ?? [:]
        self.onlineViewingUsers = (try? container.decodeIfPresent([String: [OWRealTimeOnlineViewingUsers]].self, forKey: .onlineViewingUsers)) ?? [:]
        self.conversationNewMessages = (try? container.decodeIfPresent([String: [OWComment]].self, forKey: .conversationNewMessages)) ?? [:]
        self.onlineUsers = (try? container.decodeIfPresent([String: [OWRealTimeOnlineUser]].self, forKey: .onlineUsers)) ?? [:]
    }
}

extension OWRealTimeData {

    fileprivate func getConversationId(forPostId postId: OWPostId) -> String {
        return "\(OWManager.manager.spotId)_\(postId)"
    }

    func totalCommentsCount(forPostId postId: OWPostId) -> Int {
        let commentsCounter = commentsCount(forPostId: postId)
        let repliesCounter = repliesCount(forPostId: postId)

        return commentsCounter + repliesCounter
    }

    func repliesCount(forPostId postId: OWPostId) -> Int {
        let conversationId = self.getConversationId(forPostId: postId)

        return conversationCountMessages[conversationId]?.first?.replies ?? 0
    }

    func commentsCount(forPostId postId: OWPostId) -> Int {
        let conversationId = self.getConversationId(forPostId: postId)

        return conversationCountMessages[conversationId]?.first?.comments ?? 0
    }

    func totalTypingCount(forPostId postId: OWPostId) -> Int {
        let conversationId = self.getConversationId(forPostId: postId)
        guard let typingCountDataArray = conversationTypingV2Users[conversationId] else { return 0 }

        return typingCountDataArray.first(where: { $0.key == Metrics.typingCountKey })?.count ?? 0
    }

    func newComments(forPostId postId: OWPostId) -> [OWComment] {
        let conversationId = self.getConversationId(forPostId: postId)

        return conversationNewMessages[conversationId] ?? []
    }

    func onlineViewingUsersCount(forPostId postId: OWPostId) -> OWRealTimeOnlineViewingUsers {
        let conversationId = self.getConversationId(forPostId: postId)

        return onlineViewingUsers[conversationId]?.first ?? Metrics.defaultRealTimeOnlineViewingUsers
    }

    func onlineUsers(forPostId postId: OWPostId) -> [OWRealTimeOnlineUser] {
        let conversationId = self.getConversationId(forPostId: postId)

        return onlineUsers[conversationId] ?? []
    }
}
