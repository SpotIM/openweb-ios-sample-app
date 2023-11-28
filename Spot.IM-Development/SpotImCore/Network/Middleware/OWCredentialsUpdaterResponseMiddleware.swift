//
//  OWCredentialsUpdaterResponseMiddleware.swift
//  SpotImCore
//
//  Created by Alon Haiut on 16/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

class OWCredentialsUpdaterResponseMiddleware: OWResponseMiddleware {

    fileprivate let servicesProvider: OWSharedServicesProviding

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }

    func process<T: Any>(response: OWNetworkDataResponse<T, OWNetworkError>) -> OWNetworkDataResponse<T, OWNetworkError> {
        if let httpResponse = response.response, response.error == nil {
            let authenticationManager = servicesProvider.authenticationManager()
            authenticationManager.updateNetworkCredentials(from: httpResponse)
        }

        return response
    }
}
