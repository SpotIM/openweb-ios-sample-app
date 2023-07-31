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
    case sendBatchEvents(events: [OWAnalyticEventServer])

    // MARK: - HTTPMethod
    var method: OWNetworkHTTPMethod {
        switch self {
        case .sendBatchEvents:
            return .post
        }
    }

    // MARK: - Path
    var path: String {
        switch self {
        case .sendBatchEvents:
            return "/events/batch"
        }
    }

    // MARK: - Parameters
    var parameters: OWNetworkParameters? {
        switch self {
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
    func sendEvents(events: [OWAnalyticEventServer]) -> OWNetworkResponse<OWBatchAnalyticsResponse>
}

extension OWNetworkAPI: OWAnalyticsAPI {
    // Access by .analytics for readability
    var analytics: OWAnalyticsAPI { return self }

    func sendEvents(events: [OWAnalyticEventServer]) -> OWNetworkResponse<OWBatchAnalyticsResponse> {
        let endpoint = OWAnalyticsEndpoints.sendBatchEvents(events: events)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}
