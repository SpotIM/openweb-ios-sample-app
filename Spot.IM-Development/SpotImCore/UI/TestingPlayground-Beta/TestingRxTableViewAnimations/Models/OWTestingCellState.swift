//
//  OWTestingCellState.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import Foundation

enum OWTestingCellState {
    case collapsed
    case expanded

    var opposite: OWTestingCellState {
        switch self {
        case .collapsed:
            return .expanded
        case .expanded:
            return .collapsed
        }
    }
}

#endif
