//
//  OWShadowable.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 21/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

enum OWShadowType: Equatable {
    case none, standard, custom(offset: CGSize, opacity: Float, radius: CGFloat, color: UIColor)
}

enum OWShadowDirection {
    case down, up, all
}

protocol OWShadowable {
    func apply(shadow type: OWShadowType)
    func apply(shadow type: OWShadowType, direction: OWShadowDirection)
}

private extension OWShadowType {
    var offset: CGSize {
        switch self {
        case .none: return .zero
        case .standard: return CGSize(width: 0, height: 2)
        case .custom(let offset, _, _, _): return offset
        }
    }

    var opacity: Float {
        switch self {
        case .none: return 0
        case .standard: return 0.07
        case .custom(_, let opacity, _, _): return opacity
        }
    }

    var radius: CGFloat {
        switch self {
        case .none: return 0
        case .standard: return 20
        case .custom(_, _, let radius, _): return radius
        }
    }

    var color: UIColor {
        switch self {
        case .none: return .clear
        case .standard: return .black
        case .custom(_, _, _, let color): return color
        }
    }
}

extension UIView: OWShadowable {
    func apply(shadow type: OWShadowType) {
        apply(shadow: type, direction: .down)
    }

    func apply(shadow type: OWShadowType, direction: OWShadowDirection) {
        var offset = type.offset
        switch direction {
        case .up:
            offset.height *= -1
        case .all:
            offset = .zero
        case .down:
            break
        }

        layer.shadowColor = type.color.cgColor
        layer.shadowRadius = type.radius
        layer.shadowOffset = offset
        layer.shadowOpacity = type.opacity
        layer.masksToBounds = type == .none
    }
}
