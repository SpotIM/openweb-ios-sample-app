//
//  OWSupportedLanguage+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 01/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

extension OWLanguageStrategy {
    static func languageStrategy(fromIndex index: Int, language: OWSupportedLanguage) -> OWLanguageStrategy {
        switch index {
        case OWLanguageStrategyIndexer.useDevice.index: return .useDevice
        case OWLanguageStrategyIndexer.useServerConfig.index: return .useServerConfig
        case OWLanguageStrategyIndexer.use.index: return .use(language: language)
        default: return `default`
        }
    }

    static var defaultStrategyIndex: Int {
        return OWLanguageStrategyIndexer.useDevice.index
    }

    static var `default`: OWLanguageStrategy {
        return .useDevice
    }

    enum CodingKeys: String, CodingKey {
        case useDevice
        case useServerConfig
        case use
    }
}
