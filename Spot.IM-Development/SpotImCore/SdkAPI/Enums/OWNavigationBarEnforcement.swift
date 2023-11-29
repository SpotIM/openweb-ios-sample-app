//
//  OWNavigationBarEnforcement.swift
//  SpotImCore
//
//  Created by Alon Haiut on 12/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

public enum OWNavigationBarEnforcement {
    case keepOriginal
    case style(_ style: OWNavigationBarStyle)

    public static func == (lhs: OWNavigationBarEnforcement, rhs: OWNavigationBarEnforcement) -> Bool {
        switch (lhs, rhs) {
        case (.keepOriginal, .keepOriginal):
            return true
        case (let .style(lhsStyle), let .style(rhsStyle)):
            return lhsStyle == rhsStyle
        default:
            return false
        }
    }
}
