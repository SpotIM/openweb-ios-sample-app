//
//  OWAppealEndpoints.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 08/11/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWAppealEndpoints: OWEndpoints {
    case  isEligibleToAppeal(commentId: String)

    // MARK: - HTTPMethod
    var method: OWNetworkHTTPMethod {
        switch self {
        case .isEligibleToAppeal: return .get
        }
    }

    // MARK: - Path
    var path: String {
        switch self {
        case .isEligibleToAppeal: return "conversation/v2/appeal"
        }
    }

    // MARK: - Parameters
    var parameters: OWNetworkParameters? {
        switch self {
        case .isEligibleToAppeal(let commentId):
            return ["message_id": commentId]
        }
    }
}

protocol OWAppealAPI {
    func isEligibleToAppeal(commentId: String) -> OWNetworkResponse<IsEligibleToAppealResponse>
}

extension OWNetworkAPI: OWAppealAPI {
    // Access by .appeal for readability
    var commenterAppeal: OWAppealAPI { return self }

    func isEligibleToAppeal(commentId: String) -> OWNetworkResponse<IsEligibleToAppealResponse> {
        let endpoint = OWAppealEndpoints.isEligibleToAppeal(commentId: commentId)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}

struct IsEligibleToAppealResponse: Codable {
    var canAppeal: Bool
}

