//
//  OWWeakEncapsulation.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/10/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

class OWWeakEncapsulation<T: AnyObject> {
    weak fileprivate var _value: T?

    init(value: T) {
        self._value = value
    }
    
    func value() -> T? {
        return _value
    }
}
