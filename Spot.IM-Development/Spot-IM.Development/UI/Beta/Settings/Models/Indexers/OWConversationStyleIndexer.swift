//
//  OWConversationStyleIndexer.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 17/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWConversationStyleIndexer {
    case regular
    case compact
    case custom

    var index: Int {
        switch self {
        case .regular: return 0
        case .compact: return 1
        case .custom: return 2
        }
    }
}
