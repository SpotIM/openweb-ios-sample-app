//
//  OWSession.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/04/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

/*
 OWSessionProtocol - Defining our own session protocol so we can do more complex stuff in the future
 Also we will be independent of network infrastructure in the future if we will choose so
 */
protocol OWSessionProtocol {
    var afSession: OWNetworkSession { get }
}

class OWSession: OWSessionProtocol {
    let configuration: URLSessionConfiguration
    let interceptor: OWNetworkRequestInterceptor

    static var `default`: OWSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        let retryableHttpMethods: Set<OWNetworkHTTPMethod> = [.delete, .get, .head, .options, .put, .trace, .post]
        let interceptor = OWNetworkAuthorizationRecoveryInterceptor()
        return OWSession(configuration: configuration, interceptor: interceptor)
    }()

    init(configuration: URLSessionConfiguration, interceptor: OWNetworkRequestInterceptor) {
        self.configuration = configuration
        self.interceptor = interceptor
    }

    lazy var afSession: OWNetworkSession = {
        OWNetworkSession(configuration: configuration, interceptor: interceptor)
    }()
}
