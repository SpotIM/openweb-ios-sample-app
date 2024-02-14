//
//  OWFontGroupFamily+Extensions.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 19/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

extension OWFontGroupFamily {
    var fontFamilyName: String {
        switch self {
        case .`default`:
            return "OpenSans"
        case .custom(let fontFamily):
            return fontFamily
        }
    }
}
