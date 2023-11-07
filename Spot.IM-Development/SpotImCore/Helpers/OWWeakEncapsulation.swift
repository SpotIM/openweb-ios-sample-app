//
//  OWWeakEncapsulation.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/10/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

class OWWeakEncapsulation<T: AnyObject & Equatable>: Hashable {
    static func == (lhs: OWWeakEncapsulation<T>, rhs: OWWeakEncapsulation<T>) -> Bool {
        guard let lhsValue = lhs._value,
              let rhsValue = rhs._value else { return false }

        return lhsValue == rhsValue
    }

    func hash(into hasher: inout Hasher) {
        guard let value = _value else { return hasher.combine(UUID().uuidString) }

        return ObjectIdentifier(value).hash(into: &hasher)
    }

    weak fileprivate var _value: T?

    init(value: T) {
        self._value = value
    }

    func value() -> T? {
        return _value
    }
}
