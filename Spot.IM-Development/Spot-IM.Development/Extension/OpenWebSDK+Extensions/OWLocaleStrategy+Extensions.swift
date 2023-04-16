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
        case 0: return .useDevice
        case 1: return .useServerConfig
        default: return `default`
        }
    }

    static var `default`: OWLocaleStrategy {
        // This will be returned as a default strategy
        return .useDevice
    }

    static var defaultLocaleIndex: Int {
        return 0
    }

    enum CodingKeys: String, CodingKey {
        case useDevice
        case useServerConfig
    }
}

#endif
