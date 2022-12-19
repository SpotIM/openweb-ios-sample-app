//
//  SPRealtimeDataProvider.swift
//  SpotImCore
//
//  Created by Eugene on 12.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

internal protocol SPRealtimeDataProvider {
    
    var isFetching: Bool { get }
    func fetchRealtimeData(
        conversationId: String,
        completion: @escaping (_ response: RealTimeModel?, _ error: SPNetworkError?) -> Void
    )
}

final class DefaultRealtimeDataProvider: NetworkDataProvider, SPRealtimeDataProvider {
    
    private(set) var isFetching: Bool = false
    private var currentRequest: DataRequest?
    
    func fetchRealtimeData(
        conversationId: String,
        completion: @escaping (_ response: RealTimeModel?, _ error: SPNetworkError?) -> Void) {
        isFetching = true
        currentRequest?.cancel()
        guard let spotKey = SPClientSettings.main.spotKey else {
            let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
            completion(nil, SPNetworkError.custom(message))
            return
        }
        
        let spRequest = SPRealtimeDataRequest.read
        let parameters = realTimeParameters(conversationId: "\(spotKey)_\(conversationId)", date: Date())
        let headers = HTTPHeaders.basic(with: spotKey,
                                        postId: conversationId)
        currentRequest = manager.execute(
            request: spRequest,
            parameters: parameters,
            parser: OWDecodableParser<RealTimeModel>(),
            headers: headers
        ) { [weak self] result, _ in
            self?.isFetching = false
            switch result {
            case .success(let realTimeData):
                completion(realTimeData, nil)
                
            case .failure(let error):
                completion(nil, error.spError())
            }
        }
    }
    
    private func realTimeParameters(conversationId: String, date: Date) -> [String: Any] {
        let timestamp: Int = Int(date.timeIntervalSince1970)
        let conversationId: [String: Any] = [RealtimeAPIKeys.conversationId: conversationId]
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
    
    private enum RealtimeAPIKeys {
        
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
