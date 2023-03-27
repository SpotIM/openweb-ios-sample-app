//
//  OWRequestLogger.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

class OWRequestLogger: OWNetworkLogging, OWRequestMiddleware {
    fileprivate let servicesProvider: OWSharedServicesProviding

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }

    func process(request: URLRequest) -> URLRequest {
        log(request: request)
        return request
    }

    func log(request: URLRequest) {
        let logger = servicesProvider.logger()
        var message: String

        /*
         This is a rare case in which we would like to print everything in the same output.
         Usually we will use the logger to print each thing with appropriate level.
         Here everything will be printed under the same level (medium level)
         */

        // Basic
        message = "\n[Network Request]\nURL: \(request.url?.description ?? "Missing")\nHTTP Method: \(request.method?.rawValue ?? "Missing")"

        // Headers
        if logger.logLevel == .verbose,
           !request.headers.isEmpty {
            message += "\nHeaders:"
            for header in request.headers {
                message += "\n\(header.name): \(header.value)"
            }
        }

        // Body
        if let bodyData = request.httpBody,
            let body = String(data: bodyData, encoding: .utf8) {
            message += "\nHTTP body:"
            message += "\n\(body)"
        }

        logger.log(level: .medium, message)
    }
}
