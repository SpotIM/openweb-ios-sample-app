//
//  OWReadOnlyMode+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 24/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

extension OWReadOnlyMode {
    static func readOnlyMode(fromIndex index: Int) -> OWReadOnlyMode {
        switch index {
        case OWReadOnlyMode.server.index: return .server
        case OWReadOnlyMode.enable.index: return .enable
        case OWReadOnlyMode.disable.index: return .disable
        default: return `default`
        }
    }

    static var `default`: OWReadOnlyMode {
        return .server
    }

    var index: Int {
        switch self {
        case .server: return 0
        case .enable: return 1
        case .disable: return 2
        default: return OWReadOnlyMode.`default`.index
        }
    }
}
