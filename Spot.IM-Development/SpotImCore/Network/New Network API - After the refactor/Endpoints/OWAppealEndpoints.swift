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
    case submitAppeal(commentId: String, reason: OWAppealReasonType, message: String)

    // MARK: - HTTPMethod
    var method: OWNetworkHTTPMethod {
        switch self {
        case .appealOptions: return .get
        case .isEligibleToAppeal: return .get
        case .submitAppeal: return .post
        }
    }

    // MARK: - Path
    var path: String {
        switch self {
        case .appealOptions: return "conversation/v2/appeal/options"
        case .isEligibleToAppeal: return "conversation/v2/appeal"
        case .submitAppeal: return "conversation/v2/appeal/message"
        }
    }

    // MARK: - Parameters
    var parameters: OWNetworkParameters? {
        switch self {
        case .appealOptions:
            return nil
        case .isEligibleToAppeal:
            return nil
        case let .submitAppeal(commentId, reason, message):
            return [
                "message_id": commentId,
                "reason": reason.rawValue,
                "message": message
            ]
        }
    }

    var queryParams: [Foundation.URLQueryItem]? {
        switch self {
        case .appealOptions:
            return nil
        case .isEligibleToAppeal(let commentId):
            return [Foundation.URLQueryItem(name: "messageId", value: commentId)]
        case .submitAppeal:
            return nil
        }
    }
}

protocol OWAppealAPI {
    func getAppealOptions() -> OWNetworkResponse<Array<OWAppealReason>>
    func isEligibleToAppeal(commentId: String) -> OWNetworkResponse<IsEligibleToAppealResponse>
    func submitAppeal(commentId: String, reason: OWAppealReasonType, message: String) -> OWNetworkResponse<OWNetworkEmpty>
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

    func submitAppeal(commentId: String, reason: OWAppealReasonType, message: String) -> OWNetworkResponse<OWNetworkEmpty> {
        let endpoint = OWAppealEndpoints.submitAppeal(commentId: commentId, reason: reason, message: message)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}

struct IsEligibleToAppealResponse: Codable {
    var canAppeal: Bool
}

