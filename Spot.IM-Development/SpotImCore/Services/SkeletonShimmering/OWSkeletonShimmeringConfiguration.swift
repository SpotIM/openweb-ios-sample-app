//
//  OWSkeletonShimmeringConfiguration.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/10/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

struct OWSkeletonShimmeringConfiguration {
    var shimmeringDirection: OWShimmeringDirection
    let duration: Int // In milliseconds
    let backgroundColor: OWColor.OWType
    let highlightColor: OWColor.OWType

    mutating func direction(_ direction: OWShimmeringDirection) {
        shimmeringDirection = direction
    }
}

extension OWSkeletonShimmeringConfiguration {
    static let `default`: OWSkeletonShimmeringConfiguration = {
        let config = OWSkeletonShimmeringConfiguration(shimmeringDirection: .rightToLeft,
                                          duration: 1000,
                                          backgroundColor: .skeletonColor,
                                          highlightColor: .skeletonShimmeringColor)
        return config
    }()

    static var defaultLeftToRight: OWSkeletonShimmeringConfiguration = {
        var config = OWSkeletonShimmeringConfiguration.default
        config.direction(.leftToRight)
        return config
    }()
}
