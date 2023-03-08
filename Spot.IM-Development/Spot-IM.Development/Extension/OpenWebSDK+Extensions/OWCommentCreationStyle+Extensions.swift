//
//  OWCommentCreationStyle+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 28/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API

extension OWCommentCreationStyle {
    static func commentCreationStyle(fromIndex index: Int) -> OWCommentCreationStyle {
        switch index {
        case 0: return .regular
        case 1: return .light
        case 2: return .floatingKeyboard
        default: return .regular
        }
    }
}

#endif
