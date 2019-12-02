//
//  SPConfigRequests.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 25/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

internal enum SPConfigRequests: SPRequest {
    
    case config(spotId: String)
    case adsConfig
    
    internal var method: HTTPMethod {
        switch self {
        case .config: return .get
        case .adsConfig: return .post
        }
    }

    internal var pathString: String {
        switch self {
        case .config(let spotId): return "/config/get/\(spotId)/default"
        case .adsConfig: return "/ads_config"
        }
    }

    internal var url: URL! {
        return URL(string: APIConstants.baseURLString.appending(pathString))
    }
}
