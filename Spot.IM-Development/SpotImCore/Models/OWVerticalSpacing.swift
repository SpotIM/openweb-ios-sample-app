//
//  OWVerticalSpacing.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 17/01/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import Foundation

struct OWVerticalSpacing {
    let top: CGFloat
    let bottom: CGFloat

    init(top: CGFloat = 0, bottom: CGFloat = 0) {
        self.top = top
        self.bottom = bottom
    }

    init(_ spacing: CGFloat) {
        self.top = spacing
        self.bottom = spacing
    }
}

extension OWVerticalSpacing {
    static let zero: OWVerticalSpacing = OWVerticalSpacing()
}
