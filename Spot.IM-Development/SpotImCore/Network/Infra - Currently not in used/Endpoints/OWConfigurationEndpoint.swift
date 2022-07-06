//
//  OWConfigurationEndpoint.swift
//  SpotImCore
//
//  Created by Alon Haiut on 30/06/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

// TODO: Complete OWConfigurationEndpoint

enum OWConfigurationEndpoint: OWEndpoint {
    case fetchConfig(spotId: OWSpotId)
    
    // MARK: - HTTPMethod
    var method: HTTPMethod {
        switch self {
        case .fetchConfig:
            return .get
        }
    }
    
    // MARK: - Path
    var path: String {
        switch self {
        case .fetchConfig:
            return ""
        }
    }
    
    // MARK: - Parameters
    var parameters: Parameters? {
        switch self {
        case .fetchConfig:
            return nil
        }
    }
}

protocol OWConfigurationAPI {
    func fetchConfig(spotId: OWSpotId) -> OWNetworkResponse<SPSpotConfiguration>
}

extension OWNetworkAPI: OWConfigurationAPI {
    // Access by .realtime for readability
    var configuration: OWConfigurationAPI { return self }
    
    func fetchConfig(spotId: OWSpotId) -> OWNetworkResponse<SPSpotConfiguration> {
        let endpoint = OWConfigurationEndpoint.fetchConfig(spotId: spotId)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}
