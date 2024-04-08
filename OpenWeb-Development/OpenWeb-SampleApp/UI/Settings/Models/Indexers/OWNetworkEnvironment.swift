//
//  OWNetworkEnvironment.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 21/02/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

enum OWNetworkEnvironment: Codable {
    case production
    case staging

    var index: Int {
        switch self {
        case .production: return 0
        case .staging: return 1
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
        default:
            self = OWNetworkEnvironment.default
        }
    }
}
