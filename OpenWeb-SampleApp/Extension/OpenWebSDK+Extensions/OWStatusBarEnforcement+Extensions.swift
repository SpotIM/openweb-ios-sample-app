//
//  OWStatusBarEnforcement+Extensions.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 01/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import OpenWebSDK

extension OWStatusBarEnforcement {
    static func statusBarStyle(fromIndex index: Int) -> OWStatusBarEnforcement {
        switch index {
        case OWStatusBarEnforcement.matchTheme.index: return .matchTheme
        case OWStatusBarEnforcement.style(.lightContent).index: return .style(.lightContent)
        case OWStatusBarEnforcement.style(.darkContent).index: return .style(.darkContent)
        default: return `default`
        }
    }

    static var `default`: OWStatusBarEnforcement {
        return .matchTheme
    }

    var index: Int {
        switch self {
        case .matchTheme: return 0
        case .style(.lightContent): return 1
        case .style(.darkContent): return 2
        default: return OWStatusBarEnforcement.`default`.index
        }
    }
}
