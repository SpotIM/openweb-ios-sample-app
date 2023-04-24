//
//  OWCommunityGuidelinesStyle+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 23/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API

extension OWCommunityGuidelinesStyle {
    init(index: Int) {
        switch index {
        case 0: self = .none
        case 1: self = .regular
        case 2: self = .compact
        default:
            self = .none
        }
    }

    static var defaultIndex: Int {
        return 1
    }

    enum CodingKeys: String, CodingKey {
        case none
        case regular
        case compact
    }
}

#endif
