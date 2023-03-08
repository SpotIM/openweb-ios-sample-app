//
//  OWLanguageStrategy+Extensions.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

extension OWLanguageStrategy {
    static var `default`: OWLanguageStrategy {
        // This will be returned as a default strategy
        return OWLanguageStrategy.useDevice
    }
}

#if NEW_API
extension OWLanguageStrategy: Equatable {
    public static func == (lhs: OWLanguageStrategy, rhs: OWLanguageStrategy) -> Bool {
        switch (lhs, rhs) {
        case (.useDevice, .useDevice):
            return true
        case (.useServerConfig, .useServerConfig):
            return true
        case (.use(language: let lhsLanguage), .use(language: let rhsLanguage)):
            return lhsLanguage == rhsLanguage
        default:
            return false
        }
    }
}
#else
extension OWLanguageStrategy: Equatable {
    static func == (lhs: OWLanguageStrategy, rhs: OWLanguageStrategy) -> Bool {
        switch (lhs, rhs) {
        case (.useDevice, .useDevice):
            return true
        case (.useServerConfig, .useServerConfig):
            return true
        case (.use(language: let lhsLanguage), .use(language: let rhsLanguage)):
            return lhsLanguage == rhsLanguage
        default:
            return false
        }
    }
}
#endif
