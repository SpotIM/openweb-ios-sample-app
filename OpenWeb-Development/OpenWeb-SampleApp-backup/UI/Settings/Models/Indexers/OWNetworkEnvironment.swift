//
//  OWNetworkEnvironment.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 21/02/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK

enum OWNetworkEnvironment: Codable {
    case production
    case staging
    case cluster1d

    var index: Int {
        switch self {
        case .production: return 0
        case .staging: return 1
        case .cluster1d: return 2
        }
    }

    static var `default`: OWNetworkEnvironment {
        return .production
    }

    init(from index: Int) {
        switch index {
        case OWNetworkEnvironment.production.index:
            self = .production
        case OWNetworkEnvironment.staging.index:
            self = .staging
        case OWNetworkEnvironment.cluster1d.index:
            self = .cluster1d
        default:
            self = OWNetworkEnvironment.default
        }
    }
}

#if BETA
extension OWNetworkEnvironment {
    var toSDKEnvironmentType: OWNetworkEnvironmentType {
        switch self {
        case .production:
            return .production
        case .staging:
            return .staging
        case .cluster1d:
            return .cluster1d
        }
    }
}
#endif
