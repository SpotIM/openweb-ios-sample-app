//
//  OWStatusBarEnforcement.swift
//  SpotImCore
//
//  Created by Alon Haiut on 01/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

#if NEW_API
public enum OWStatusBarEnforcement {
    case matchTheme
    case style(_ style: UIStatusBarStyle)

    public static func == (lhs: OWStatusBarEnforcement, rhs: OWStatusBarEnforcement) -> Bool {
        switch (lhs, rhs) {
        case (.matchTheme, .matchTheme):
            return true
        case (let .style(lhsStyle), let .style(rhsStyle)):
            return lhsStyle == rhsStyle
        default:
            return false
        }
    }
}
#else
enum OWStatusBarEnforcement {
    case matchTheme
    case style(_ style: UIStatusBarStyle)

    static func == (lhs: OWStatusBarEnforcement, rhs: OWStatusBarEnforcement) -> Bool {
        switch (lhs, rhs) {
        case (.matchTheme, .matchTheme):
            return true
        case (let .style(lhsStyle), let .style(rhsStyle)):
            return lhsStyle == rhsStyle
        default:
            return false
        }
    }
}
#endif
