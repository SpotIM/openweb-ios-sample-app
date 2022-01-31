//
//  SPAdsConfigRequest.swift
//  SpotImCore
//
//  Created by Eugene on 30.10.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

internal enum SPAdsConfigRequest: SPRequest {
    case adsConfig

    internal var method: HTTPMethod {
        switch self {
        case .adsConfig: return .post
        }
    }

    internal var pathString: String {
        switch self {
        case .adsConfig: return "/ads_config"
        }
    }

    internal var url: URL! {
        return URL(string: APIConstants.baseURLString.appending(pathString))
    }
}
