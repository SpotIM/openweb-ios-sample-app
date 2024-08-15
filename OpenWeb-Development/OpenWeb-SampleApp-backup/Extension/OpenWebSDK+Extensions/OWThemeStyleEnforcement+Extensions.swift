//
//  OWThemeStyleEnforcement+Extensions.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 23/01/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK

extension OWThemeStyleEnforcement {
    static func themeStyle(fromIndex index: Int) -> OWThemeStyleEnforcement {
        switch index {
        case OWThemeStyleEnforcement.none.index: return .none
        case OWThemeStyleEnforcement.theme(.light).index: return .theme(.light)
        case OWThemeStyleEnforcement.theme(.dark).index: return .theme(.dark)
        default: return `default`
        }
    }

    static var `default`: OWThemeStyleEnforcement {
        return .none
    }

    var index: Int {
        switch self {
        case .none: return 0
        case .theme(.light): return 1
        case .theme(.dark): return 2
        default: return OWThemeStyleEnforcement.`default`.index
        }
    }
}
