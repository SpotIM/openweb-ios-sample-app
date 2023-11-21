//
//  OWAppealEndpoints.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 08/11/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWAppealEndpoints: OWEndpoints {
    case appealOptions
    case isEligibleToAppeal(commentId: String)

    // MARK: - HTTPMethod
    var method: OWNetworkHTTPMethod {
        switch self {
        case .appealOptions: return .get
        case .isEligibleToAppeal: return .get
        }
    }

    // MARK: - Path
    var path: String {
        switch self {
        case .appealOptions: return "conversation/v2/appeal/options"
        case .isEligibleToAppeal: return "conversation/v2/appeal"
        }
    }

    // MARK: - Parameters
    var parameters: OWNetworkParameters? {
        switch self {
        case .appealOptions:
            return nil
        case .isEligibleToAppeal:
            return nil
        }
    }

    var queryParams: [Foundation.URLQueryItem]? {
        switch self {
        case .appealOptions:
            return nil
        case .isEligibleToAppeal(let commentId):
            return [Foundation.URLQueryItem(name: "messageId", value: commentId)]
        }
    }
}

protocol OWAppealAPI {
    func getAppealOptions() -> OWNetworkResponse<Array<OWAppealReason>>
    func isEligibleToAppeal(commentId: String) -> OWNetworkResponse<IsEligibleToAppealResponse>
}

extension OWNetworkAPI: OWAppealAPI {
    // Access by .appeal for readability
    var appeal: OWAppealAPI { return self }

    func getAppealOptions() -> OWNetworkResponse<Array<OWAppealReason>> {
        let endpoint = OWAppealEndpoints.appealOptions
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func isEligibleToAppeal(commentId: String) -> OWNetworkResponse<IsEligibleToAppealResponse> {
        let endpoint = OWAppealEndpoints.isEligibleToAppeal(commentId: commentId)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}

struct IsEligibleToAppealResponse: Codable {
    var canAppeal: Bool
}

