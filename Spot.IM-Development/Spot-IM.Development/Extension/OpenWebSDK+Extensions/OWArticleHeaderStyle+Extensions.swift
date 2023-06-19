//
//  OWArticleHeaderStyle+Extensions.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 19/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API

extension OWArticleHeaderStyle {
    static func articleHeaderStyle(fromIndex index: Int) -> OWArticleHeaderStyle {
        switch index {
        case 0: return .none
        case 1: return .regular
        default: return `default`
        }
    }

    static var `default`: OWArticleHeaderStyle {
        return .regular
    }

    var index: Int {
        switch self {

        case .none:
            return 0
        case .regular:
            return 1
        default:
            return OWArticleHeaderStyle.`default`.index
        }
    }
}

#endif
