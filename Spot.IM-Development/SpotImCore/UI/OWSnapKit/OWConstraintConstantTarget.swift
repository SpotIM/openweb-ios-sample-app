//
//  OWConstraintConstantTarget.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

protocol OWConstraintConstantTarget {}

extension CGPoint: OWConstraintConstantTarget {}

extension CGSize: OWConstraintConstantTarget {}

extension UIEdgeInsets: OWConstraintConstantTarget {}

extension OWConstraintConstantTarget {
    func constraintConstantTargetValueFor(layoutAttribute: OWLayoutAttribute) -> CGFloat {
        if let value = self as? CGFloat {
            return value
        }

        if let value = self as? Float {
            return CGFloat(value)
        }

        if let value = self as? Double {
            return CGFloat(value)
        }

        if let value = self as? Int {
            return CGFloat(value)
        }

        if let value = self as? UInt {
            return CGFloat(value)
        }

        if let value = self as? CGSize {
            if layoutAttribute == .width {
                return value.width
            } else if layoutAttribute == .height {
                return value.height
            } else {
                return 0.0
            }
        }

        if let value = self as? CGPoint {
                switch layoutAttribute {
                case .left, .right, .leading, .trailing, .centerX, .leftMargin, .rightMargin, .leadingMargin, .trailingMargin, .centerXWithinMargins:
                    return value.x
                case .top, .bottom, .centerY, .topMargin, .bottomMargin, .centerYWithinMargins, .lastBaseline, .firstBaseline:
                    return value.y
                case .width, .height, .notAnAttribute:
                    return 0.0
                @unknown default:
                    return 0.0
            }
        }

        if let value = self as? UIEdgeInsets {
                switch layoutAttribute {
                case .left, .leftMargin:
                    return value.left
                case .top, .topMargin, .firstBaseline:
                    return value.top
                case .right, .rightMargin:
                    return -value.right
                case .bottom, .bottomMargin, .lastBaseline:
                    return -value.bottom
                case .leading, .leadingMargin:
                    return (OWConstraintConfig.interfaceLayoutDirection == .leftToRight) ? value.left : value.right
                case .trailing, .trailingMargin:
                    return (OWConstraintConfig.interfaceLayoutDirection == .leftToRight) ? -value.right : -value.left
                case .centerX, .centerXWithinMargins:
                    return (value.left - value.right) / 2
                case .centerY, .centerYWithinMargins:
                    return (value.top - value.bottom) / 2
                case .width:
                    return -(value.left + value.right)
                case .height:
                    return -(value.top + value.bottom)
                case .notAnAttribute:
                    return 0.0
                @unknown default:
                    return 0.0
            }
        }

        return 0.0
    }
}
