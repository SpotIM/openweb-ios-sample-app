//
//  OWStatusBarEnforcement+Extensions.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 01/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import SpotImCore

extension OWStatusBarEnforcement {
    static func statusBarStyle(fromIndex index: Int) -> OWStatusBarEnforcement {
        switch index {
        case OWStatusBarEnforcement.matchTheme.index: return .matchTheme
        case OWStatusBarEnforcement.style(.lightContent).index: return .style(.lightContent)
        default:
            if #available(iOS 13.0, *) {
                if index == OWStatusBarEnforcement.style(.darkContent).index {
                    return .style(.darkContent)
                } else {
                    return `default`
                }
            } else {
                return `default`
            }
        }
    }

    static var `default`: OWStatusBarEnforcement {
        return .matchTheme
    }

    var index: Int {
        switch self {
        case .matchTheme: return 0
        case .style(.lightContent): return 1
        default:
            if #available(iOS 13.0, *) {
                if self == .style(.darkContent) {
                    return 2
                } else {
                    return OWStatusBarEnforcement.`default`.index
                }
            } else {
                return OWStatusBarEnforcement.`default`.index
            }
        }
    }
}
