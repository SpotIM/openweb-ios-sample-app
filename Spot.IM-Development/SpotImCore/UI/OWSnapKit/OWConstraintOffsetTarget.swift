//
//  OWConstraintOffsetTarget.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

protocol OWConstraintOffsetTarget: OWConstraintConstantTarget {}

extension Int: OWConstraintOffsetTarget {}

extension UInt: OWConstraintOffsetTarget {}

extension Float: OWConstraintOffsetTarget {}

extension Double: OWConstraintOffsetTarget {}

extension CGFloat: OWConstraintOffsetTarget {}

extension OWConstraintOffsetTarget {
    var constraintOffsetTargetValue: CGFloat {
        let offset: CGFloat
        if let amount = self as? Float {
            offset = CGFloat(amount)
        } else if let amount = self as? Double {
            offset = CGFloat(amount)
        } else if let amount = self as? CGFloat {
            offset = CGFloat(amount)
        } else if let amount = self as? Int {
            offset = CGFloat(amount)
        } else if let amount = self as? UInt {
            offset = CGFloat(amount)
        } else {
            offset = 0.0
        }
        return offset
    }
}
