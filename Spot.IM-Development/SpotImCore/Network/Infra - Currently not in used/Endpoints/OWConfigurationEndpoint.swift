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

enum OWConfigurationEndpoint: OWEndpoint {
    case fetchConfig(spotId: OWSpotId)
    case fetchAdsConfig
    case fetchAbTestData
    
    // MARK: - HTTPMethod
    var method: HTTPMethod {
        switch self {
        case .fetchConfig:
            return .get
        case .fetchAdsConfig:
            return .post
        case .fetchAbTestData:
            return .get
        }
    }
    
    // MARK: - Path
    var path: String {
        switch self {
        case .fetchConfig(let spotId):
            return "/config/get/\(spotId)/default"
        case .fetchAdsConfig:
            return "/ads_config"
        case .fetchAbTestData:
            return "/config/ab_test"
        }
    }
    
    // MARK: - Parameters
    var parameters: Parameters? {
        switch self {
        case .fetchConfig:
            return nil
        case .fetchAdsConfig:
            let date = Date()
            let dayName = Date.dayNameFormatter.string(from: date).lowercased()
            let hour = Int(Date.hourFormatter.string(from: date))!
            return ["day": dayName, "hour": hour]
        case .fetchAbTestData:
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
