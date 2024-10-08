//
//  OWArticleHeaderStyle+Extensions.swift
//  OpenWeb-Development
//
//  Created by Revital Pisman on 19/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK

extension OWArticleHeaderStyle {
    static func articleHeaderStyle(fromIndex index: Int) -> OWArticleHeaderStyle {
        switch index {
        case OWArticleHeaderStyle.none.index: return .none
        case OWArticleHeaderStyle.regular.index: return .regular
        default:
            return `default`
        }
    }

    static var `default`: OWArticleHeaderStyle {
        return .regular
    }

    var index: Int {
        switch self {
        case .none: return 0
        case .regular: return 1
        default:
            return OWArticleHeaderStyle.`default`.index
        }
    }
}
