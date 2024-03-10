//
//  Range+OWExtension.swift
//  SpotImCore
//
//  Created by Refael Sommer on 07/03/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import Foundation

extension Range {
    // swiftlint:disable operator_whitespace
    static func ~=(lhs: Self, rhs: Self) -> Bool {
        rhs.clamped(to: lhs) == rhs
    }
}
