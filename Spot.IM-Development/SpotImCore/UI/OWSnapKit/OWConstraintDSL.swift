//
//  OWConstraintDSL.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

protocol OWConstraintDSL {
    var target: AnyObject? { get }

    func setLabel(_ value: String?)
    func label() -> String?
}

private var labelKey: UInt8 = 0

extension OWConstraintDSL {
    func setLabel(_ value: String?) {
        objc_setAssociatedObject(self.target as Any, &labelKey, value, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    func label() -> String? {
        return objc_getAssociatedObject(self.target as Any, &labelKey) as? String
    }
}

protocol OWConstraintBasicAttributesDSL: OWConstraintDSL {}

extension OWConstraintBasicAttributesDSL {

    // MARK: Basics
    var left: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.left)
    }

    var top: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.top)
    }

    var right: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.right)
    }

    var bottom: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.bottom)
    }

    var leading: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.leading)
    }

    var trailing: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.trailing)
    }

    var width: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.width)
    }

    var height: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.height)
    }

    var centerX: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.centerX)
    }

    var centerY: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.centerY)
    }

    var edges: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.edges)
    }

    var directionalEdges: OWConstraintItem {
      return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.directionalEdges)
    }

    var horizontalEdges: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.horizontalEdges)
    }

    var verticalEdges: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.verticalEdges)
    }

    var directionalHorizontalEdges: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.directionalHorizontalEdges)
    }

    var directionalVerticalEdges: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.directionalVerticalEdges)
    }

    var size: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.size)
    }

    var center: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.center)
    }
}

protocol OWConstraintAttributesDSL: OWConstraintBasicAttributesDSL {}

extension OWConstraintAttributesDSL {

    var lastBaseline: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.lastBaseline)
    }

    var firstBaseline: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.firstBaseline)
    }

    // MARK: Margins
    var leftMargin: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.leftMargin)
    }

    var topMargin: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.topMargin)
    }

    var rightMargin: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.rightMargin)
    }

    var bottomMargin: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.bottomMargin)
    }

    var leadingMargin: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.leadingMargin)
    }

    var trailingMargin: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.trailingMargin)
    }

    var centerXWithinMargins: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.centerXWithinMargins)
    }

    var centerYWithinMargins: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.centerYWithinMargins)
    }

    var margins: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.margins)
    }

    var directionalMargins: OWConstraintItem {
      return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.directionalMargins)
    }

    var centerWithinMargins: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.centerWithinMargins)
    }
}
