//
//  NetworkTestingUtil.swift
//  OpenWebCoreTests
//
//  Created by Alon Haiut on 15/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
@testable import SpotImCore

enum NetwrokError: Error {
    case generalFailure
}

class NetworkTestingUtil {
    func requestHandler(for environment: OWEnvironment,
                        with data: Data,
                        endpoint: OWEndpoints,
                        statusCode: Int = 200,
                        method: OWNetworkHTTPMethod = .get) -> (URLRequest, MockURLProtocol.RequestHandler) {

        return (
            try! URLRequest( // swiftlint:disable:this force_try
                url: environment.baseURL.appendingPathComponent(endpoint.path),
                method: method
            ), { request in
                // swiftlint:disable:next force_try
                let response = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: "2.0", headerFields: nil)!
                return (response, data)
            }
        )
    }

    func response(with api: OWNetworkAPI,
                  for endpoint: OWEndpoints,
                  decoder: JSONDecoder = JSONDecoder()) -> OWNetworkResponse<MockUser> {

        return api.performRequest(
            route: api.request(for: endpoint),
            decoder: decoder
        )
    }
}
