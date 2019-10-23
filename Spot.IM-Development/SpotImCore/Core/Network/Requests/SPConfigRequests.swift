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

    internal var method: HTTPMethod {
        switch self {
        case .config: return .get
        }
    }

    internal var pathString: String {
        switch self {
        case .config(let spotId): return "/config/get/\(spotId)/default"
        }
    }

    internal var url: URL! {
        return URL(string: APIConstants.baseURLString.appending(pathString))
    }
}
