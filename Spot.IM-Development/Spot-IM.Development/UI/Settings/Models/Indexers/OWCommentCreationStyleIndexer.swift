//
//  OWCommentCreationStyleIndexer.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 23/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWCommentCreationStyleIndexer {
    case regular
    case light
    case floatingKeyboard

    var index: Int {
        switch self {
        case .regular: return 0
        case .light: return 1
        case .floatingKeyboard: return 2
        }
    }
}
