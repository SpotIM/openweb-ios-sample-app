//
//  Range+OWExtension.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 07/03/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

extension Range {
    // swiftlint:disable operator_whitespace
    // This checks if a range is congruent with another range
    static func ~=(lhs: Self, rhs: Self) -> Bool {
        rhs.clamped(to: lhs) == rhs
    }
}
