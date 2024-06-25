//
//  OWSortOption.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 08/11/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

public enum OWSortOption: String {
    case best
    case newest
    case oldest

    internal var sortMenu: OWSortMenu {
        switch self {
        case .best:
            return .sortBest
        case .newest:
            return .sortNewest
        case .oldest:
            return .sortOldest
        }
    }
}
