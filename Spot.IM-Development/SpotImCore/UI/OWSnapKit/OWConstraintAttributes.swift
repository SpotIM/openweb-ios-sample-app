//
//  OWConstraintAttributes.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

struct OWConstraintAttributes : OptionSet, ExpressibleByIntegerLiteral {
    
    typealias IntegerLiteralType = UInt
    
    init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    init(integerLiteral rawValue: IntegerLiteralType) {
        self.init(rawValue: rawValue)
    }
    private init(_ rawValue: UInt) {
        self.init(rawValue: rawValue)
    }
    private init(nilLiteral: ()) {
        self.rawValue = 0
    }
    private(set) var rawValue: UInt
    private static var allZeros: OWConstraintAttributes { return 0 }
    private static func convertFromNilLiteral() -> OWConstraintAttributes { return 0 }
    private var boolValue: Bool { return self.rawValue != 0 }
    
    private func toRaw() -> UInt { return self.rawValue }
    private static func fromRaw(_ raw: UInt) -> OWConstraintAttributes? { return self.init(raw) }
    private static func fromMask(_ raw: UInt) -> OWConstraintAttributes { return self.init(raw) }
    
    // normal
    static let none: OWConstraintAttributes = 0
    static let left: OWConstraintAttributes = OWConstraintAttributes(UInt(1) << 0)
    static let top: OWConstraintAttributes = OWConstraintAttributes(UInt(1) << 1)
    static let right: OWConstraintAttributes = OWConstraintAttributes(UInt(1) << 2)
    static let bottom: OWConstraintAttributes = OWConstraintAttributes(UInt(1) << 3)
    static let leading: OWConstraintAttributes = OWConstraintAttributes(UInt(1) << 4)
    static let trailing: OWConstraintAttributes = OWConstraintAttributes(UInt(1) << 5)
    static let width: OWConstraintAttributes = OWConstraintAttributes(UInt(1) << 6)
    static let height: OWConstraintAttributes = OWConstraintAttributes(UInt(1) << 7)
    static let centerX: OWConstraintAttributes = OWConstraintAttributes(UInt(1) << 8)
    static let centerY: OWConstraintAttributes = OWConstraintAttributes(UInt(1) << 9)
    static let lastBaseline: OWConstraintAttributes = OWConstraintAttributes(UInt(1) << 10)
    static let firstBaseline: OWConstraintAttributes = OWConstraintAttributes(UInt(1) << 11)
    
    static let leftMargin: OWConstraintAttributes = OWConstraintAttributes(UInt(1) << 12)
    
    static let rightMargin: OWConstraintAttributes = OWConstraintAttributes(UInt(1) << 13)
    
    static let topMargin: OWConstraintAttributes = OWConstraintAttributes(UInt(1) << 14)
    
    static let bottomMargin: OWConstraintAttributes = OWConstraintAttributes(UInt(1) << 15)
    
    static let leadingMargin: OWConstraintAttributes = OWConstraintAttributes(UInt(1) << 16)
    
    static let trailingMargin: OWConstraintAttributes = OWConstraintAttributes(UInt(1) << 17)
    
    static let centerXWithinMargins: OWConstraintAttributes = OWConstraintAttributes(UInt(1) << 18)
    
    static let centerYWithinMargins: OWConstraintAttributes = OWConstraintAttributes(UInt(1) << 19)
    
    // aggregates
    static let edges: OWConstraintAttributes = [.horizontalEdges, .verticalEdges]
    static let horizontalEdges: OWConstraintAttributes = [.left, .right]
    static let verticalEdges: OWConstraintAttributes = [.top, .bottom]
    static let directionalEdges: OWConstraintAttributes = [.directionalHorizontalEdges, .directionalVerticalEdges]
    static let directionalHorizontalEdges: OWConstraintAttributes = [.leading, .trailing]
    static let directionalVerticalEdges: OWConstraintAttributes = [.top, .bottom]
    static let size: OWConstraintAttributes = [.width, .height]
    static let center: OWConstraintAttributes = [.centerX, .centerY]
    
    static let margins: OWConstraintAttributes = [.leftMargin, .topMargin, .rightMargin, .bottomMargin]
    
    static let directionalMargins: OWConstraintAttributes = [.leadingMargin, .topMargin, .trailingMargin, .bottomMargin]
    
    static let centerWithinMargins: OWConstraintAttributes = [.centerXWithinMargins, .centerYWithinMargins]
    
    var layoutAttributes:[OWLayoutAttribute] {
        var attrs = [OWLayoutAttribute]()
        if (self.contains(OWConstraintAttributes.left)) {
            attrs.append(.left)
        }
        if (self.contains(OWConstraintAttributes.top)) {
            attrs.append(.top)
        }
        if (self.contains(OWConstraintAttributes.right)) {
            attrs.append(.right)
        }
        if (self.contains(OWConstraintAttributes.bottom)) {
            attrs.append(.bottom)
        }
        if (self.contains(OWConstraintAttributes.leading)) {
            attrs.append(.leading)
        }
        if (self.contains(OWConstraintAttributes.trailing)) {
            attrs.append(.trailing)
        }
        if (self.contains(OWConstraintAttributes.width)) {
            attrs.append(.width)
        }
        if (self.contains(OWConstraintAttributes.height)) {
            attrs.append(.height)
        }
        if (self.contains(OWConstraintAttributes.centerX)) {
            attrs.append(.centerX)
        }
        if (self.contains(OWConstraintAttributes.centerY)) {
            attrs.append(.centerY)
        }
        if (self.contains(OWConstraintAttributes.lastBaseline)) {
            attrs.append(.lastBaseline)
        }
        if (self.contains(OWConstraintAttributes.firstBaseline)) {
            attrs.append(.firstBaseline)
        }
        if (self.contains(OWConstraintAttributes.leftMargin)) {
            attrs.append(.leftMargin)
        }
        if (self.contains(OWConstraintAttributes.rightMargin)) {
            attrs.append(.rightMargin)
        }
        if (self.contains(OWConstraintAttributes.topMargin)) {
            attrs.append(.topMargin)
        }
        if (self.contains(OWConstraintAttributes.bottomMargin)) {
            attrs.append(.bottomMargin)
        }
        if (self.contains(OWConstraintAttributes.leadingMargin)) {
            attrs.append(.leadingMargin)
        }
        if (self.contains(OWConstraintAttributes.trailingMargin)) {
            attrs.append(.trailingMargin)
        }
        if (self.contains(OWConstraintAttributes.centerXWithinMargins)) {
            attrs.append(.centerXWithinMargins)
        }
        if (self.contains(OWConstraintAttributes.centerYWithinMargins)) {
            attrs.append(.centerYWithinMargins)
        }
        
        return attrs
    }
}

func + (left: OWConstraintAttributes, right: OWConstraintAttributes) -> OWConstraintAttributes {
    return left.union(right)
}

func +=(left: inout OWConstraintAttributes, right: OWConstraintAttributes) {
    left.formUnion(right)
}

func -=(left: inout OWConstraintAttributes, right: OWConstraintAttributes) {
    left.subtract(right)
}

func ==(left: OWConstraintAttributes, right: OWConstraintAttributes) -> Bool {
    return left.rawValue == right.rawValue
}
