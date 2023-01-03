//
//  URLSessionConfiguration+Network.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

extension URLSessionConfiguration: OWNetworkExtended {}
extension OWNetworkExtension where ExtendedType: URLSessionConfiguration {
    /// OWNetwork's default configuration. Same as `URLSessionConfiguration.default` but adds OWNetwork default
    /// `Accept-Language`, `Accept-Encoding`, and `User-Agent` headers.
    static var `default`: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default

        return configuration
    }

    /// `.ephemeral` configuration with OWNetwork's default `Accept-Language`, `Accept-Encoding`, and `User-Agent`
    /// headers.
    static var ephemeral: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.headers = .default

        return configuration
    }
}
