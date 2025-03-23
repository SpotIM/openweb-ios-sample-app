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
    case staging(namespace: String? = "")
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

    init(from index: Int, namespace: String? = nil) {
        switch index {
        case OWNetworkEnvironment.production.index:
            self = .production
        case OWNetworkEnvironment.staging(namespace: namespace).index:
            self = .staging(namespace: namespace)
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
        case .staging(let namespace):
            return .staging(namespace: namespace)
        case .cluster1d:
            return .cluster1d
        }
    }
}
#endif
