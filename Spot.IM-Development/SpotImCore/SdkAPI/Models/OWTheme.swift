//
//  OWTheme.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 05/12/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

public struct OWTheme {
    public let backgroundColor1: OWColor? // TODO: remove!!
    public let skeletonColor: OWColor?

    public init(backgroundColor1: OWColor? = nil,
                skeletonColor: OWColor? = nil
    ) {
        self.backgroundColor1 = backgroundColor1
        self.skeletonColor = skeletonColor
    }
}
