//
//  OWEnvironment.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 19/04/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

/*
 OWEnvironmentProtocol - configuration protocol which present the environment we are working on
 */
protocol OWEnvironmentProtocol {
    var scheme: String { get }
    var domain: String { get }
    var baseURL: URL { get }
}

class OWEnvironment: OWEnvironmentProtocol {
    let scheme: String
    let domain: String

    static var currentEnvironment: OWEnvironmentProtocol = production

    static var production = OWEnvironment(scheme: "https", domain: "mobile-gw.spot.im")
    static var staging = OWEnvironment(scheme: "https", domain: "dev.staging-spot.im/proxy/staging-v2/mobile-gw/8000")

    static func set(environment: OWEnvironmentProtocol) {
        currentEnvironment = environment
    }

    init(scheme: String, domain: String) {
        self.scheme = scheme
        self.domain = domain
    }

    lazy var baseURL: URL = {
        let urlString = "\(scheme)://\(domain)"
        return URL(string: urlString)!
    }()
}
