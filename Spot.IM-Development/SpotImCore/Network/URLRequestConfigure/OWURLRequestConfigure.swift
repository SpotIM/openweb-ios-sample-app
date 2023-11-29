//
//  OWURLRequestConfigure.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

/*
 OWURLRequestConfiguration - configuration protocol which is used for building the HTTP request
 */
protocol OWURLRequestConfiguration: OWNetworkURLRequestConvertible {
    var environment: OWEnvironmentProtocol { get }
    var endpoint: OWEndpoints { get }
    func asURLRequest() throws -> URLRequest
}

extension OWURLRequestConfiguration {
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {

        let url = try (endpoint.overrideBaseURL ?? environment.baseURL).asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(endpoint.path))

        // HTTP Method
        urlRequest.httpMethod = endpoint.method.rawValue

        // Parameters
        if let parameters = endpoint.parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                throw OWNetworkError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        }

        return urlRequest
    }
}

struct OWURLRequestConfigure: OWURLRequestConfiguration {
    var environment: OWEnvironmentProtocol
    var endpoint: OWEndpoints
}
