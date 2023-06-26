//
//  OWReadOnlyMode+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 24/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API

extension OWReadOnlyMode {
    static func readOnlyMode(fromIndex index: Int) -> OWReadOnlyMode {
        switch index {
        case 0: return .server
        case 1: return .enable
        case 2: return .disable
        default: return .server
        }
    }

    static var defaultIndex: Int {
        return 0
    }
}

#endif
