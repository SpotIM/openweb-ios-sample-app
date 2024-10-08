//
//  OWAccessoryViewStrategy+Extensions.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 16/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK
import UIKit

extension OWAccessoryViewStrategy {
    init(index: Int) {
        switch index {
        case OWAccessoryViewStrategy.none.index: self = .none
        case OWAccessoryViewStrategy.bottomToolbar(toolbar: UIView()).index: self = .bottomToolbar(toolbar: UIView())
        default:
            self = OWAccessoryViewStrategy.default
        }
    }

    static var `default`: OWAccessoryViewStrategy {
        return .none
    }

    var index: Int {
        switch self {
        case .none: return 0
        case .bottomToolbar: return 1
        default: return OWAccessoryViewStrategy.`default`.index
        }
    }
}
