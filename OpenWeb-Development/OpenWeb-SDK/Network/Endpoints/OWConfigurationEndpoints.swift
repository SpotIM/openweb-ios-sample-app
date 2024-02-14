//
//  OWConfigurationEndpoint.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 30/06/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

enum OWConfigurationEndpoints: OWEndpoints {
    case fetchConfig(spotId: OWSpotId)
    case fetchAdsConfig
    case fetchAbTestData

    // MARK: - HTTPMethod
    var method: OWNetworkHTTPMethod {
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
    var parameters: OWNetworkParameters? {
        switch self {
        case .fetchConfig:
            return nil
        case .fetchAdsConfig:
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat  = "EEEE"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            let dayName = dateFormatter.string(from: date).lowercased()
            dateFormatter.dateFormat  = "HH"
            let hour = Int(dateFormatter.string(from: date))!
            return ["day": dayName, "hour": hour]
        case .fetchAbTestData:
            return nil
        }
    }
}

protocol OWConfigurationAPI {
    func fetchConfig(spotId: OWSpotId) -> OWNetworkResponse<SPSpotConfiguration>
    func fetchAdsConfig() -> OWNetworkResponse<SPAdsConfiguration>
    func fetchAbTestData() -> OWNetworkResponse<OWAbTests>
}

extension OWNetworkAPI: OWConfigurationAPI {
    // Access by .configuration for readability
    var configuration: OWConfigurationAPI { return self }

    func fetchConfig(spotId: OWSpotId) -> OWNetworkResponse<SPSpotConfiguration> {
        let endpoint = OWConfigurationEndpoints.fetchConfig(spotId: spotId)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func fetchAdsConfig() -> OWNetworkResponse<SPAdsConfiguration> {
        let endpoint = OWConfigurationEndpoints.fetchAdsConfig
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func fetchAbTestData() -> OWNetworkResponse<OWAbTests> {
        let endpoint = OWConfigurationEndpoints.fetchAbTestData
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}
