//
//  IntegerType+OWIdentifiableType.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

extension BinaryInteger {
    typealias Identity = Self

    var identity: Self {
        return self
    }
}

extension Int: OWIdentifiableType {}

extension Int8: OWIdentifiableType {}

extension Int16: OWIdentifiableType {}

extension Int32: OWIdentifiableType {}

extension Int64: OWIdentifiableType {}

extension UInt: OWIdentifiableType {}

extension UInt8: OWIdentifiableType {}

extension UInt16: OWIdentifiableType {}

extension UInt32: OWIdentifiableType {}

extension UInt64: OWIdentifiableType {}
