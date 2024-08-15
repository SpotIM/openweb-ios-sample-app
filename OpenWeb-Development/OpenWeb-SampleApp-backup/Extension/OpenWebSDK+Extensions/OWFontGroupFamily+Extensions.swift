//
//  OWFontGroupFamily+Extensions.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 28/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK

extension OWFontGroupFamily {
    static func fontGroupFamily(fromIndex index: Int, name: String = "") -> OWFontGroupFamily {
        switch index {
        case OWFontGroupFamilyIndexer.`default`.index: return .`default`
        case OWFontGroupFamilyIndexer.custom.index: return .custom(fontFamily: name)
        default:
            return .`default`
        }
    }

    enum CodingKeys: String, CodingKey {
        case `default`
        case custom
    }
}
