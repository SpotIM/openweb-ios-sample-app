//
//  SPAnalyticsFacade.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 02/09/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

internal protocol SPAnalyticsSender {
    func sendEvent(with info: SPAnalyticsEventInfo, postId: String?)
}

internal final class SPDefaultAnalyticsSender: NetworkDataProvider, SPAnalyticsSender {

    func sendEvent(with info: SPAnalyticsEventInfo, postId: String?) {

        guard let spotKey = SPClientSettings.main.spotKey else {
            Logger.error("[ERROR]: No spot key for analytics")
            return
        }

        let spRequest = SPAnalyticsRequest.analytics

        var parameters: Parameters = [
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
        
        var headers = HTTPHeaders.basic(with: spotKey)
        if let postId = postId {
            headers = HTTPHeaders.basic(with: spotKey, postId: postId)
        }
        
        manager.execute(
            request: spRequest,
            parameters: parameters,
            parser: EmptyParser(),
            headers: headers
        ) { _, response in
            SPUserSessionHolder.updateSession(with: response.response)
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

public struct SPAnalyticsEventInfo {
    let eventType: String
    let source: String
    let isRegistered: Bool
    let splitName: String

    let itemType: String?
    let targetType: String?
    let segment: String?
    let lang: String?
    let domain: String?
    let userId: String?
    let messageId: String?
    let relatedMessageId: String?
    let readingSeconds: Int?
    let itemId: String?
    let totalComments: Int?
    let engineStatusType: String?
    let publisherCustomData: [String: String]?
}
