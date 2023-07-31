//
//  OWLocaleStrategy+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 19/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API

extension OWLocaleStrategy {
    static func localeStrategy(fromIndex index: Int) -> OWLocaleStrategy {
        switch index {
        case OWLocaleStrategy.useDevice.index: return .useDevice
        case OWLocaleStrategy.useServerConfig.index: return .useServerConfig
        default: return `default`
        }
    }

    static var `default`: OWLocaleStrategy {
        // This will be returned as a default strategy
        return .useDevice
    }

    var index: Int {
        switch self {
        case .useDevice: return 0
        case .useServerConfig: return 1
        case .`default`: return 2
        default: return OWLocaleStrategy.`default`.index
        }
    }

    enum CodingKeys: String, CodingKey {
        case useDevice
        case useServerConfig
    }
}

#endif
