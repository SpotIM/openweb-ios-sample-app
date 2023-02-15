//
//  OWRequestLogger.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

class OWRequestLogger: OWNetworkLogging, OWRequestMiddleware {
    func process(request: URLRequest) -> URLRequest {
        if let url = request.url {
            log(output: "Network send request: \(url)")
        }
        return request
    }

    func log(output: String) {
        // TODO: Complete the logger. Process function will probably be changed based on the log level
    }
}
