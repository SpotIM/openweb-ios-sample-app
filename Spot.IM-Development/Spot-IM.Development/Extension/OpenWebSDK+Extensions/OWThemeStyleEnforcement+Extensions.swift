//
//  OWThemeStyleEnforcement+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 23/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API

extension OWThemeStyleEnforcement {
    static func themeStyle(fromIndex index: Int) -> OWThemeStyleEnforcement {
        switch index {
        case 0: return .none
        case 1: return .theme(.light)
        case 2: return .theme(.dark)
        default: return .none
        }
    }
}

#endif
