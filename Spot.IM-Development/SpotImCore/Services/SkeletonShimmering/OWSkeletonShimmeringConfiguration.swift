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
    let duration: TimeInterval // In seconds
    let backgroundColor: UIColor
    let highlightColor: UIColor
    
    mutating func direction(_ direction: OWShimmeringDirection) {
        shimmeringDirection = direction
    }
}

extension OWSkeletonShimmeringConfiguration {
    static let `default` = OWSkeletonShimmeringConfiguration(shimmeringDirection: .rightToLeft,
                                                             duration: 1.0,
                                                             backgroundColor: UIColor.skeletonBackgroundColor,
                                                             highlightColor: UIColor.skeletonHighlightColor)
    
    static var defaultLeftToRight: OWSkeletonShimmeringConfiguration = {
        var config = OWSkeletonShimmeringConfiguration.default
        config.direction(.leftToRight)
        return config
    }()
}
