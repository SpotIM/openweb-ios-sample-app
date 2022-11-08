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
    let backgroundColor: UIColor
    let highlightColor: UIColor
    
    mutating func direction(_ direction: OWShimmeringDirection) {
        shimmeringDirection = direction
    }
}

extension OWSkeletonShimmeringConfiguration {
    static let `default` = {
        let currentStyle = OWSharedServicesProvider.shared.themeStyleService().currentStyle
        let skeletonColor = OWColorPalette.shared.color(type: .skeletonColor,
                                                       themeStyle: currentStyle)
        let shimmeringColor = OWColorPalette.shared.color(type: .skeletonShimmeringColor,
                                                       themeStyle: currentStyle)
        let config = OWSkeletonShimmeringConfiguration(shimmeringDirection: .rightToLeft,
                                          duration: 1000,
                                          backgroundColor: skeletonColor,
                                          highlightColor: shimmeringColor)
        return config
    }()
    
    static var defaultLeftToRight: OWSkeletonShimmeringConfiguration = {
        var config = OWSkeletonShimmeringConfiguration.default
        config.direction(.leftToRight)
        return config
    }()
}
