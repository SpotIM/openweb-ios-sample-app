//
//  SPLogLevel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 02/05/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

// This entire file can be removed after refactoring prefix to OW

public enum SPLogLevel {
    case none, error, medium, verbose
}

extension SPLogLevel {
    var toOWPrefix: OWLogLevel {
        switch self {
        case .none:
            return .none
        case .error:
            return .error
        case .medium:
            return .medium
        case .verbose:
            return .verbose
        }
    }
}
