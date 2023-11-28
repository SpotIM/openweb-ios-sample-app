//
//  OWFontGroupFamilyIndexer.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 17/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWFontGroupFamilyIndexer {
    case `default`
    case custom

    var index: Int {
        switch self {
        case .`default`: return 0
        case .custom: return 1
        }
    }
}
