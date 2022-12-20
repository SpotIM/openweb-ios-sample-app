//
//  URLRequest+Network.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

extension URLRequest {
    /// Returns the `httpMethod` as OWNetwork's `HTTPMethod` type.
    var method: OWNetworkHTTPMethod? {
        get { httpMethod.flatMap(OWNetworkHTTPMethod.init) }
        set { httpMethod = newValue?.rawValue }
    }

    func validate() throws {
        if method == .get, let bodyData = httpBody {
            throw OWNetworkError.urlRequestValidationFailed(reason: .bodyDataInGETRequest(bodyData))
        }
    }
}
