//
//  OWInitialSortStrategy+Extensions.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 23/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK

extension OWInitialSortStrategy {
    static func initialSort(fromIndex index: Int) -> OWInitialSortStrategy {
        switch index {
        case OWInitialSortStrategy.useServerConfig.index: return .useServerConfig
        case OWInitialSortStrategy.use(sortOption: .best).index: return .use(sortOption: .best)
        case OWInitialSortStrategy.use(sortOption: .newest).index: return .use(sortOption: .newest)
        case OWInitialSortStrategy.use(sortOption: .oldest).index: return .use(sortOption: .oldest)
        default: return .useServerConfig
        }
    }

    static var `default`: OWInitialSortStrategy {
        return .useServerConfig
    }

    // swiftlint:disable no_magic_numbers
    var index: Int {
        switch self {
        case .useServerConfig: return 0
        case .use(sortOption: .best): return 1
        case .use(sortOption: .newest): return 2
        case .use(sortOption: .oldest): return 3
        default: return OWInitialSortStrategy.`default`.index
        }
    }
    // swiftlint:enable no_magic_numbers
}
