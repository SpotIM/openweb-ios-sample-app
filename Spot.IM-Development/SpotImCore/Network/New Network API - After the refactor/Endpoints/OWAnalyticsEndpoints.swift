//
//  OWAnalyticsEndpoint.swift
//  SpotImCore
//
//  Created by Alon Haiut on 24/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

enum OWAnalyticsEndpoints: OWEndpoints {
    case sendEvent(info: SPEventInfo)
    case sendBatchEvents(events: [OWAnalyticEventServer])

    // MARK: - HTTPMethod
    var method: OWNetworkHTTPMethod {
        switch self {
        case .sendEvent:
            return .post
        case .sendBatchEvents:
            return .post
        }
    }

    // MARK: - Path
    var path: String {
        switch self {
        case .sendEvent:
            return "/event"
        case .sendBatchEvents:
            return "/events/batch"
        }
    }

    // MARK: - Parameters
    var parameters: OWNetworkParameters? {
        switch self {
        case .sendEvent(let info):
            // TODO: Decide if we want to send an empty string in case of a nil or to not send the field as all
            let params: OWNetworkParameters = [
                "type": info.eventType,
                "source": info.source,
                "item_type": info.itemType ?? "",
                "target_type": info.targetType ?? "",
                "segment": info.segment ?? "",
                "lang": info.lang ?? "",
                "domain": info.domain ?? "",
                "user_id": info.userId ?? "",
                "message_id": info.messageId ?? "",
                "related_message_id": info.relatedMessageId ?? "",
                "item_id": info.itemId ?? "",
                "count": info.readingSeconds ?? "",
                "is_registered": info.isRegistered,
                "total_comments": info.totalComments ?? "",
                "engine_status": info.engineStatusType ?? "",
                "split_name": info.splitName,
                "publisher_custom_data": info.publisherCustomData ?? ""
            ]

            return params
        case .sendBatchEvents(let events):
            let params = ["events": events]
            let encoder: JSONEncoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let datadata = try? encoder.encode(params)
            guard let datadata = datadata else { return [:] }
            let json = try? JSONSerialization.jsonObject(with: datadata, options: []) as? [String: Any]
            guard let json = json else { return [:] }
            return json
        }
    }
}

protocol OWAnalyticsAPI {
    func sendEvent(info: SPEventInfo) -> OWNetworkResponse<Bool>
    func sendEvents(events: [OWAnalyticEvent]) -> OWNetworkResponse<Bool>
}

extension OWNetworkAPI: OWAnalyticsAPI {
    // Access by .analytics for readability
    var analytics: OWAnalyticsAPI { return self }

    func sendEvent(info: SPEventInfo) -> OWNetworkResponse<Bool> {
        let endpoint = OWAnalyticsEndpoints.sendEvent(info: info)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    // TODO: send events to BE and return real res
    func sendEvents(events: [OWAnalyticEvent]) -> OWNetworkResponse<Bool> {
        let serverEvents: [OWAnalyticEventServer] = events.map {
            OWSharedServicesProvider.shared
                .analyticsEventCreatorService()
                .serverAnalyticEvent(from: $0)
        }
        let endpoint = OWAnalyticsEndpoints.sendBatchEvents(events: serverEvents)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}
