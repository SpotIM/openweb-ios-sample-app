//
//  OWFailureReportEndpoint.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 25/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

enum OWFailureReportEndpoints: OWEndpoints {
    case error(error: SPError)

    // MARK: - HTTPMethod
    var method: OWNetworkHTTPMethod {
        switch self {
        case .error:
            return .post
        }
    }

    // MARK: - Path
    var path: String {
        switch self {
        case .error:
            return "/error"
        }
    }

    // MARK: - Parameters
    var parameters: OWNetworkParameters? {
        switch self {
        case .error(let error):
            return error.parameters()
        }
    }
}

protocol OWFailureReportAPI {
    func reportError(error: SPError) -> OWNetworkResponse<EmptyDecodable>
}

extension OWNetworkAPI: OWFailureReportAPI {
    // Access by .failureReporter for readability
    var failureReporter: OWFailureReportAPI { return self }

    func reportError(error: SPError) -> OWNetworkResponse<EmptyDecodable> {
        let endpoint = OWFailureReportEndpoints.error(error: error)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}
