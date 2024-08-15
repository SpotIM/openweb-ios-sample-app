//
//  OWOrientationEnforcement+Extensions.swift
//  OpenWeb-Development
//
//  Created by  Nogah Melamed on 17/10/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK

extension OWOrientationEnforcement {
    static func orientationEnforcement(fromIndex index: Int) -> OWOrientationEnforcement {
        switch index {
        case OWOrientationEnforcement.enableAll.index:
            return .enableAll
        case OWOrientationEnforcement.enable(orientations: [.portrait]).index:
            return .enable(orientations: [.portrait])
        case OWOrientationEnforcement.enable(orientations: [.landscape]).index:
            return .enable(orientations: [.landscape])
        default:
            return `default`
        }
    }

    static var `default`: OWOrientationEnforcement {
        return .enableAll
    }

    var index: Int {
        switch self {
        case .enableAll: return 0
        case .enable(let orientations):
            if orientations.count == 1 {
                switch orientations[0] {
                case .portrait:
                    return 1
                case .landscape:
                    return 2
                @unknown default:
                    // Intentionally crash the Sample App in this case
                    fatalError()
                }
            }
            return 0
        default:
            return OWOrientationEnforcement.`default`.index
        }
    }
}
