//
//  OWConstraintInsetTarget.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

protocol OWConstraintInsetTarget: OWConstraintConstantTarget {}

extension Int: OWConstraintInsetTarget {}

extension UInt: OWConstraintInsetTarget {}

extension Float: OWConstraintInsetTarget {}

extension Double: OWConstraintInsetTarget {}

extension CGFloat: OWConstraintInsetTarget {}

extension UIEdgeInsets: OWConstraintInsetTarget {}

extension OWConstraintInsetTarget {
    var constraintInsetTargetValue: UIEdgeInsets {
        if let amount = self as? UIEdgeInsets {
            return amount
        } else if let amount = self as? Float {
            return UIEdgeInsets(top: CGFloat(amount), left: CGFloat(amount), bottom: CGFloat(amount), right: CGFloat(amount))
        } else if let amount = self as? Double {
            return UIEdgeInsets(top: CGFloat(amount), left: CGFloat(amount), bottom: CGFloat(amount), right: CGFloat(amount))
        } else if let amount = self as? CGFloat {
            return UIEdgeInsets(top: amount, left: amount, bottom: amount, right: amount)
        } else if let amount = self as? Int {
            return UIEdgeInsets(top: CGFloat(amount), left: CGFloat(amount), bottom: CGFloat(amount), right: CGFloat(amount))
        } else if let amount = self as? UInt {
            return UIEdgeInsets(top: CGFloat(amount), left: CGFloat(amount), bottom: CGFloat(amount), right: CGFloat(amount))
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
}

