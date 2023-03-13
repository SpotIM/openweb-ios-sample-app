//
//  OWSupportedLanguage+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 01/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API

extension OWLanguageStrategy {
    static func languageStrategy(fromIndex index: Int, language: OWSupportedLanguage = .defaultLanguage) -> OWLanguageStrategy {
        switch index {
        case 0: return .useDevice
        case 1: return .useServerConfig
        case 2: return .use(language: language)
        default: return defaultStrategy
        }
    }

    static var defaultStrategyIndex: Int {
        return 0
    }

    static var defaultStrategy: OWLanguageStrategy {
        .useDevice
    }

    static func languageStrategy(fromData data: Data) -> OWLanguageStrategy {
        do {
            let decoded = try JSONDecoder().decode(OWLanguageStrategy.self, from: data)
            return decoded
        } catch {
            DLog("Failed to decode languageStrategy \(error.localizedDescription)")
        }
        return defaultStrategy
    }

    var data: Data {
        let encoder = JSONEncoder()

        do {
            let data = try encoder.encode(self)
            return data
        } catch {
            DLog("Failed to encode languageStrategy \(error.localizedDescription)")
        }
        return Data()
    }

    enum CodingKeys: String, CodingKey {
        case useDevice
        case useServerConfig
        case use
    }
}

#endif
