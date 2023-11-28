//
//  OWOrientationEnforcement+Extensions.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 18/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

extension OWOrientationEnforcement {
    var interfaceOrientationMask: UIInterfaceOrientationMask {
        switch self {
        case .enableAll:
            return .all
        case .enable(let orientations):
            if orientations.count == 1 {
                switch orientations[0] {
                case .portrait:
                    return .portrait
                case .landscape:
                    return .landscape
                }
            } else {
                return .all
            }
        }
    }
}
