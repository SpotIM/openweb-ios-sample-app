//
//  OWThemeStyleEnforcement.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWThemeStyleEnforcement {
    case none
    case theme(_ theme: OWThemeStyle)

    public static func ==(lhs: OWThemeStyleEnforcement, rhs: OWThemeStyleEnforcement) -> Bool {
        switch (lhs, rhs) {
        case (let .theme(lhsStyle), let .theme(rhsStyle)):
            return lhsStyle == rhsStyle
        case (.none, .none):
            return true
        default:
            return false
        }
    }
}
#else
enum OWThemeStyleEnforcement {
    case none
    case theme(_ theme: OWThemeStyle)

    static func ==(lhs: OWThemeStyleEnforcement, rhs: OWThemeStyleEnforcement) -> Bool {
        switch (lhs, rhs) {
        case (let .theme(lhsStyle), let .theme(rhsStyle)):
            return lhsStyle == rhsStyle
        case (.none, .none):
            return true
        default:
            return false
        }
    }
}
#endif
