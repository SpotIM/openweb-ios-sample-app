//
//  SPAnalyticsFacade.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 02/09/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal protocol SPAnalyticsSender {
    func sendEvent(with info: SPEventInfo, postId: String?)
}

internal final class SPDefaultAnalyticsSender: NetworkDataProvider, SPAnalyticsSender {

    func sendEvent(with info: SPEventInfo, postId: String?) {

        guard let spotKey = SPClientSettings.main.spotKey else {
            servicesProvider.logger().log(level: .error, "No spot key for analytics")
            return
        }

        let spRequest = SPAnalyticsRequest.analytics

        var parameters: OWNetworkParameters = [
            AnalyticsAPIKeys.type: info.eventType,
            AnalyticsAPIKeys.source: info.source
        ]

        parameters[AnalyticsAPIKeys.itemType] = info.itemType
        parameters[AnalyticsAPIKeys.targetType] = info.targetType
        parameters[AnalyticsAPIKeys.segment] = info.segment
        parameters[AnalyticsAPIKeys.lang] = info.lang
        parameters[AnalyticsAPIKeys.domain] = info.domain
        parameters[AnalyticsAPIKeys.userId] = info.userId
        parameters[AnalyticsAPIKeys.messageId] = info.messageId
        parameters[AnalyticsAPIKeys.relatedMessageId] = info.relatedMessageId
        parameters[AnalyticsAPIKeys.itemId] = info.itemId
        parameters[AnalyticsAPIKeys.count] = info.readingSeconds
        parameters[AnalyticsAPIKeys.isRegistered] = info.isRegistered
        parameters[AnalyticsAPIKeys.totalComments] = info.totalComments
        parameters[AnalyticsAPIKeys.engineStatusType] = info.engineStatusType
        parameters[AnalyticsAPIKeys.splitName] = info.splitName
        parameters[AnalyticsAPIKeys.publisherCustomData] = info.publisherCustomData
        
        var headers = OWNetworkHTTPHeaders.basic(with: spotKey)
        if let postId = postId {
            headers = OWNetworkHTTPHeaders.basic(with: spotKey, postId: postId)
        }
        
        manager.execute(
            request: spRequest,
            parameters: parameters,
            parser: OWEmptyParser(),
            headers: headers
        ) { _, _ in
            // Doing nothing here. Basically we should not update user session or anything here that might mess with the authentication
        }
    }

    private enum AnalyticsAPIKeys {
        static let type = "type"
        static let source = "source"
        static let itemType = "item_type"
        static let targetType = "target_type"
        static let segment = "segment"
        static let lang = "lang"
        static let domain = "domain"
        static let userId = "user_id"
        static let messageId = "message_id"
        static let relatedMessageId = "related_message_id"

        static let itemId = "item_id"
        static let count = "count" // number of seconds reading comments
        static let isRegistered = "is_registered"
        static let totalComments = "total_comments"
        static let engineStatusType = "engine_status"
        static let splitName = "split_name"
        static let publisherCustomData = "publisher_custom_data"
    }
}

public struct SPEventInfo: Codable {
    public let eventType: String
    public let source: String
    public let isRegistered: Bool
    public let splitName: String

    public let itemType: String?
    public let targetType: String?
    public let segment: String?
    public let lang: String?
    public let domain: String?
    public let userId: String?
    public let messageId: String?
    public let relatedMessageId: String?
    public let readingSeconds: Int?
    public let itemId: String?
    public let totalComments: Int?
    public let engineStatusType: String?
    public let publisherCustomData: [String: String]?
    public let targetUrl: String?
}
