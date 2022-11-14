//
//  OWRealtimeEndpoint.swift
//  SpotImCore
//
//  Created by Alon Haiut on 29/06/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

enum OWRealtimeEndpoints: OWEndpoints {
    case fetchData(fullConversationId: String)
    
    // MARK: - HTTPMethod
    var method: HTTPMethod {
        switch self {
        case .fetchData:
            return .post
        }
    }
    
    // MARK: - Path
    var path: String {
        switch self {
        case .fetchData:
            return "/conversation/realtime/read"
        }
    }
    
    // MARK: - Parameters
    var parameters: Parameters? {
        switch self {
        case .fetchData(let fullConversationId):
            return fetchDataParameters(fullConversationId: fullConversationId)
        }
    }
}

protocol OWRealtimeAPI {
    func fetchData(fullConversationId: String) -> OWNetworkResponse<RealTimeModel>
}

extension OWNetworkAPI: OWRealtimeAPI {
    // Access by .realtime for readability
    var realtime: OWRealtimeAPI { return self }
    
    func fetchData(fullConversationId: String) -> OWNetworkResponse<RealTimeModel> {
        let endpoint = OWRealtimeEndpoints.fetchData(fullConversationId: fullConversationId)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}

fileprivate extension OWRealtimeEndpoints {
    func fetchDataParameters(fullConversationId: String) -> [String: Any] {
        let timestamp: Int = Int((Date()).timeIntervalSince1970)
        let conversationId: [String: Any] = [RealtimeAPIKeys.conversationId: fullConversationId]
        let withMessageIds = conversationId.merging([RealtimeAPIKeys.messageIds: []]) { first, _ in first }
        
        return [
            RealtimeAPIKeys.timestamp: timestamp,
            RealtimeAPIKeys.data: [
                RealtimeAPIKeys.conversationNewMessages: [conversationId],
                RealtimeAPIKeys.conversationCountMessages: [conversationId],
                RealtimeAPIKeys.onlineUsers: [conversationId],
                RealtimeAPIKeys.onlineViewingUsersCount: [withMessageIds],
                RealtimeAPIKeys.conversationUpdatedMessages: [conversationId],
                RealtimeAPIKeys.conversationDeletedMessages: [withMessageIds],
                RealtimeAPIKeys.conversationTypingV2Users: [withMessageIds],
                RealtimeAPIKeys.conversationTypingV2Count: [withMessageIds]
            ]
        ]
    }
    
    enum RealtimeAPIKeys {
        static let timestamp = "timestamp"
        static let data = "data"
        static let conversationId = "conversation_id"
        static let conversationNewMessages = "conversation/new-messages"
        static let conversationCountMessages = "conversation/count-messages"
        static let onlineUsers = "online/users"
        static let onlineViewingUsersCount = "online/users-count"
        static let conversationUpdatedMessages = "conversation/updated-messages"
        static let conversationDeletedMessages = "conversation/deleted-messages"
        static let messageIds = "message_ids"
        static let conversationTypingV2Users = "conversation/typing-v2-users"
        static let conversationTypingV2Count = "conversation/typing-v2-count"
    }
}
