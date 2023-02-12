//
//  OWModalPresentationStyle+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 23/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API

extension OWModalPresentationStyle {
    static func styleFromPersistence(index: Int) -> OWModalPresentationStyle {
        switch index {
        case 0: return .fullScreen
        case 1: return .pageSheet
        default: return .fullScreen
        }
    }
}

#endif
