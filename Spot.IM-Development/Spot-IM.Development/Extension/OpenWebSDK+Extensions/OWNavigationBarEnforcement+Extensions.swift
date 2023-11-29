//
//  OWNavigationBarEnforcement+Extensions.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 12/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

extension OWNavigationBarEnforcement {
    static func navigationBarEnforcement(fromIndex index: Int) -> OWNavigationBarEnforcement {
        switch index {
        case OWNavigationBarEnforcement.style(.largeTitles).index: return .style(.largeTitles)
        case OWNavigationBarEnforcement.style(.regular).index: return .style(.regular)
        case OWNavigationBarEnforcement.keepOriginal.index: return .keepOriginal
        default:
            return `default`
        }
    }

    static var `default`: OWNavigationBarEnforcement {
        return .style(.largeTitles)
    }

    var index: Int {
        switch self {
        case .style(.largeTitles): return 0
        case .style(.regular): return 1
        case .keepOriginal: return 2
        default:
            return OWNavigationBarEnforcement.`default`.index
        }
    }
}
