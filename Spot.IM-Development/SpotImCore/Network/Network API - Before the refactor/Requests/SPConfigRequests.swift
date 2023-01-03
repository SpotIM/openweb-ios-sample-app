//
//  SPConfigRequests.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 25/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal enum SPConfigRequests: SPRequest {
    
    case config(spotId: String)
    case adsConfig
    case abTestData
    
    internal var method: OWNetworkHTTPMethod {
        switch self {
        case .config: return .get
        case .adsConfig: return .post
        case .abTestData: return .get
        }
    }

    internal var pathString: String {
        switch self {
        case .config(let spotId): return "/config/get/\(spotId)/default"
        case .adsConfig: return "/ads_config"
        case .abTestData: return "/config/ab_test"
        }
    }

    internal var url: URL! {
        return URL(string: APIConstants.baseURLString.appending(pathString))
    }
}
