//
//  OWIdentifiableValue.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

struct OWIdentifiableValue<Value: Hashable> {
    let value: Value
}

extension OWIdentifiableValue: OWIdentifiableType {

    typealias Identity = Value

    var identity : Identity {
        return value
    }
}

extension OWIdentifiableValue: Equatable, CustomStringConvertible, CustomDebugStringConvertible {

    var description: String {
        return "\(value)"
    }

    var debugDescription: String {
        return "\(value)"
    }
}

func == <V>(lhs: OWIdentifiableValue<V>, rhs: OWIdentifiableValue<V>) -> Bool {
    return lhs.value == rhs.value
}
