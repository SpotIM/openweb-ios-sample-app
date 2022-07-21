//
//  SPAdditionalConfiguration.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

public enum SPAdditionalConfiguration {
    case suppressFinmbFilter
}

extension SPAdditionalConfiguration {
    var toOWPrefix: OWAdditionalConfiguration {
        switch self {
        case .suppressFinmbFilter:
            return .suppressFinmbFilter
        }
    }
}
