//
//  OWInitialSortStrategy+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 23/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API

extension OWInitialSortStrategy {
    static func initialSort(fromIndex index: Int) -> OWInitialSortStrategy {
        switch index {
        case 0: return .useServerConfig
        case 1: return .use(sortOption: .best)
        case 2: return .use(sortOption: .newest)
        case 3: return .use(sortOption: .oldest)
        default: return .useServerConfig
        }
    }

    static var defaultIndex: Int {
        return 0
    }
}

#endif
