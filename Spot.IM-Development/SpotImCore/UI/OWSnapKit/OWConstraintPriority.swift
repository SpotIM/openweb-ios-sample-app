//
//  OWConstraintPriority.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

struct OWConstraintPriority: ExpressibleByFloatLiteral, Equatable, Strideable {
    typealias OWFloatLiteralType = Float

    let value: Float

    init(floatLiteral value: Float) {
        self.value = value
    }

    init(_ value: Float) {
        self.value = value
    }

    static var required: OWConstraintPriority {
        return 1000.0
    }

    static var high: OWConstraintPriority {
        return 750.0
    }

    static var medium: OWConstraintPriority {
        return 500.0
    }

    static var low: OWConstraintPriority {
        return 250.0
    }

    static func ==(lhs: OWConstraintPriority, rhs: OWConstraintPriority) -> Bool {
        return lhs.value == rhs.value
    }

    // MARK: Strideable
    func advanced(by n: OWFloatLiteralType) -> OWConstraintPriority {
        return OWConstraintPriority(floatLiteral: value + n)
    }

    func distance(to other: OWConstraintPriority) -> OWFloatLiteralType {
        return other.value - value
    }
}
