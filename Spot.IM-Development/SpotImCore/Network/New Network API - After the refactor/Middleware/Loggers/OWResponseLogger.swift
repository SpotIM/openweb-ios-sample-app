//
//  OWResponseLogger.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

class OWResponseLogger: OWNetworkLogging, OWResponseMiddleware {
    fileprivate let servicesProvider: OWSharedServicesProviding

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }

    func process<T: Any>(response: OWNetworkDataResponse<T, OWNetworkError>) -> OWNetworkDataResponse<T, OWNetworkError> {
        log(responseResult: response)
        return response
    }

    func log<T: Any>(responseResult: OWNetworkDataResponse<T, OWNetworkError>) {
        let logger = servicesProvider.logger()
        var message: String
        let levelToPrint: OWLogLevel

        /*
         This is a rare case in which we would like to print everything in the same output.
         Usually we will use the logger to print each thing with appropriate level.
         Here everything will be printed under the same level (medium level by defualt, if there was an error everything will be printed as error level)
         */

        message = "\n[Network Response]\nURL: \(responseResult.request?.url?.description ?? "Missing")"

        if let error = responseResult.error {
            levelToPrint = .error
            message += "\nResponse received an error: \(error.errorDescription ?? "Missing error description")"
        } else {
            levelToPrint = .medium
        }

        // Status code and timing
        message += "\nStatus code: \(responseResult.response?.statusCode ?? 0)\nTime: \(String(format: "%.3fms", (responseResult.metrics?.taskInterval.duration ?? 0) * 1000))"

        // Headers
        if logger.logLevel == .verbose,
           let headers = responseResult.response?.headers,
           !headers.isEmpty {
            message += "\nHeaders:"
            for header in headers {
                message += "\n\(header.name): \(header.value)"
            }
        }

        // Body
        if let data = responseResult.data {
            message += "\nResponse data:"
            message += "\n\(data)"
        }

        logger.log(level: levelToPrint, message)
    }
}

