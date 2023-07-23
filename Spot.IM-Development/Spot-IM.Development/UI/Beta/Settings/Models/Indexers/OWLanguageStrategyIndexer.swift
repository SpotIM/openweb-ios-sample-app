//
//  OWLanguageStrategyIndexer.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 05/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWLanguageStrategyIndexer {
    case useDevice
    case useServerConfig
    case use

    var index: Int {
        switch self {
        case .useDevice: return 0
        case .useServerConfig: return 1
        case .use: return 2
        }
    }
}
