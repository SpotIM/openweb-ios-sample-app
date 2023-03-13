//
//  OWConversationStyle+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 28/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API

extension OWConversationStyle {
    static func conversationStyle(fromIndex index: Int) -> OWConversationStyle {
        switch index {
        case 0: return .regular
        case 1: return .compact
        default: return .regular
        }
    }

    static var defaultIndex: Int {
        return 1
    }
}

#endif
