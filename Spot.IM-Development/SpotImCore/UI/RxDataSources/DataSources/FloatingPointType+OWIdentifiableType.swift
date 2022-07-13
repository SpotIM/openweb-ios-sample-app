//
//  FloatingPointType+OWIdentifiableType.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

extension FloatingPoint {
    typealias identity = Self

    var identity: Self {
        return self
    }
}

extension Float : OWIdentifiableType {}

extension Double : OWIdentifiableType {}
