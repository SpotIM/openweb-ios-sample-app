//
//  OWRealTimeData.swift
//  OpenWebSDK
//
//  Created by Revital Pisman on 06/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import RxSwift
import RxCocoa

struct OWRealTimeData: Decodable {
    private let conversationCountMessages: [String: [OWRealTimeMessagesCount]]
    private let conversationTypingV2Count: [String: [[String: Int]]]
    private let conversationTypingV2Users: [String: [OWRealTimeTypingUsers]]
    private let conversationNewMessages: [String: [OWComment]]
    private let onlineViewingUsers: [String: [OWRealTimeOnlineViewingUsers]]
    private let onlineUsers: [String: [OWRealTimeOnlineUser]]

    enum CodingKeys: String, CodingKey {
        case conversationCountMessages = "conversation/count-messages"
        case conversationTypingV2Count = "conversation/typing-v2-count"
        case conversationTypingV2Users = "conversation/typing-v2-users"
        case conversationNewMessages = "conversation/new-messages"
        case onlineViewingUsers = "online/users-count"
        case onlineUsers = "online/users"
    }

    struct Metrics {
        static let typingCountForNewRootCommentsKey = "NewComment"
        static let defaultRealTimeOnlineViewingUsers = OWRealTimeOnlineViewingUsers(count: 1)
    }

    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)

        // If data is missing or invalid, provided default values [:]
        self.conversationCountMessages = (try? container?.decodeIfPresent([String: [OWRealTimeMessagesCount]].self, forKey: .conversationCountMessages)) ?? [:]
        self.conversationTypingV2Count = (try? container?.decodeIfPresent([String: [[String: Int]]].self, forKey: .conversationTypingV2Count)) ?? [:]
        self.conversationTypingV2Users = (try? container?.decodeIfPresent([String: [OWRealTimeTypingUsers]].self, forKey: .conversationTypingV2Users)) ?? [:]
        self.onlineViewingUsers = (try? container?.decodeIfPresent([String: [OWRealTimeOnlineViewingUsers]].self, forKey: .onlineViewingUsers)) ?? [:]
        self.conversationNewMessages = (try? container?.decodeIfPresent([String: [OWComment]].self, forKey: .conversationNewMessages)) ?? [:]
        self.onlineUsers = (try? container?.decodeIfPresent([String: [OWRealTimeOnlineUser]].self, forKey: .onlineUsers)) ?? [:]
    }
}

extension OWRealTimeData {

    private func getConversationId(forPostId postId: OWPostId) -> String {
        return "\(OWManager.manager.spotId)_\(postId)"
    }

    func totalCommentsCount(forPostId postId: OWPostId) -> Int {
        let rootCommentsCounter = rootCommentsCount(forPostId: postId)
        let repliesCounter = repliesCount(forPostId: postId)

        return rootCommentsCounter + repliesCounter
    }

    func repliesCount(forPostId postId: OWPostId) -> Int {
        let conversationId = self.getConversationId(forPostId: postId)

        return conversationCountMessages[conversationId]?.first?.replies ?? 0
    }

    func rootCommentsCount(forPostId postId: OWPostId) -> Int {
        let conversationId = self.getConversationId(forPostId: postId)

        return conversationCountMessages[conversationId]?.first?.comments ?? 0
    }

    func rootCommentsTypingCount(forPostId postId: OWPostId) -> Int {
        let conversationId = self.getConversationId(forPostId: postId)
        guard let typingCountDataArray = conversationTypingV2Users[conversationId] else { return 0 }

        return typingCountDataArray.first(where: { $0.key == Metrics.typingCountForNewRootCommentsKey })?.count ?? 0
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
