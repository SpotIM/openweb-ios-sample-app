//
//  OWResponseLogger.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

class OWResponseLogger: OWNetworkLogging, OWResponseMiddleware {
    func process<T: Any>(response: OWNetworkDataResponse<T, OWNetworkError>) -> OWNetworkDataResponse<T, OWNetworkError> {
        if let error = response.error {
            log(output: "Network error: \(error.localizedDescription)")
        } else if let url = response.request?.url {
            log(output: "Network received request: \(url)")
        }

        return response
    }

    func log(output: String) {
        // TODO: Complete the logger. Process function will probably be changed based on the log level
    }
}

