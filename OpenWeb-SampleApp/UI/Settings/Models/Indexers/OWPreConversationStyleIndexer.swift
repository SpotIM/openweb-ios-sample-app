//
//  OWPreConversationStyleIndexer.swift
//  OpenWeb-Development
//
//  Created by Revital Pisman on 04/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

enum OWPreConversationStyleIndexer {
    case regular
    case compact
    case ctaButtonOnly
    case ctaWithSummary
    case custom

    // swiftlint:disable no_magic_numbers
    var index: Int {
        switch self {
        case .regular: return 0
        case .compact: return 1
        case .ctaButtonOnly: return 2
        case .ctaWithSummary: return 3
        case .custom: return 4
        }
    }
    // swiftlint:enable no_magic_numbers
}
