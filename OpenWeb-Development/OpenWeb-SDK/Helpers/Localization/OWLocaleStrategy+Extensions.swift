//
//  OWLocaleStrategy+Extensions.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

extension OWLocaleStrategy {
    static var `default`: OWLocaleStrategy {
        // This will be returned as a default strategy
        return OWLocaleStrategy.useDevice
    }
}

extension OWLocaleStrategy: Equatable {
    public static func == (lhs: OWLocaleStrategy, rhs: OWLocaleStrategy) -> Bool {
        switch (lhs, rhs) {
        case (.useDevice, .useDevice):
            return true
        case (.useServerConfig, .useServerConfig):
            return true
        case (.use(locale: _), .use(locale: _)):
            // Force changing/updating other stuff
            return false
        default:
            return false
        }
    }
}
