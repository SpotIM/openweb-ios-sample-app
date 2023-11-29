//
//  OWFailureReportEndpoint.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 25/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

// TODO: Once we will send errors from the SDK to some reporter bucket, we will need to create a dedicate Errors enum for that

enum OWFailureReportEndpoints: OWEndpoints {
    case error(error: OWError)

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
        case .error(_):
            // TODO - create json from the error
            return [:]
        }
    }
}

protocol OWFailureReportAPI {
    func reportError(error: OWError) -> OWNetworkResponse<EmptyDecodable>
}

extension OWNetworkAPI: OWFailureReportAPI {
    // Access by .failureReporter for readability
    var failureReporter: OWFailureReportAPI { return self }

    func reportError(error: OWError) -> OWNetworkResponse<EmptyDecodable> {
        let endpoint = OWFailureReportEndpoints.error(error: error)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}
