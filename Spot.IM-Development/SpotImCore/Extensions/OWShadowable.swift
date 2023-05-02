//
//  OWShadowable.swift
//  SpotImCore
//
//  Created by Refael Sommer on 02/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

enum ShadowType {
    case none, low, medium, high
}

enum ShadowDirection {
    case down, up
}

protocol Shadowable {
    func apply(shadow type: ShadowType) -> UIView
    func apply(shadow type: ShadowType, color: UIColor) -> UIView
    func apply(shadow type: ShadowType, direction: ShadowDirection) -> UIView
    func apply(shadow type: ShadowType, color: UIColor, direction: ShadowDirection) -> UIView
}

private extension ShadowType {
    var offset: CGSize {
        switch self {
        case .none: return .zero
        case .low: return CGSize(width: 0, height: 3)
        case .medium: return CGSize(width: 0, height: 5)
        case .high: return CGSize(width: 0, height: 6)
        }
    }

    var opacity: Float {
        switch self {
        case .none: return 0
        case .low: return 0.1
        case .medium: return 0.2
        case .high: return 0.2
        }
    }

    var radius: CGFloat {
        switch self {
        case .none: return 0
        case .low: return 3
        case .medium: return 6
        case .high: return 10
        }
    }
}

extension UIView: Shadowable {
     @discardableResult func apply(shadow type: ShadowType) -> UIView {
        apply(shadow: type, color: OWDesignColors.L6, direction: .down)
         return self
    }

    @discardableResult func apply(shadow type: ShadowType, direction: ShadowDirection) -> UIView {
        apply(shadow: type, color: OWDesignColors.L6, direction: direction)
        return self
    }

    @discardableResult func apply(shadow type: ShadowType, color: UIColor) -> UIView {
        apply(shadow: type, color: color, direction: .down)
        return self
    }

    @discardableResult func apply(shadow type: ShadowType, color: UIColor, direction: ShadowDirection) -> UIView {
        var offset = type.offset
        if direction == .up {
            offset.height *= -1
        }
        layer.shadowColor = color.cgColor
        layer.shadowRadius = type.radius
        layer.shadowOffset = offset
        layer.shadowOpacity = type.opacity
        layer.masksToBounds = type == .none
        return self
    }
}
