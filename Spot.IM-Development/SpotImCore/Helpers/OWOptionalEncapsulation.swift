//
//  OWOptionalEncapsulation.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

/*
 For class types please use OWWeakEncapsulation.
 This class should be used to store callbacks and other types which are not conform to AnyObject
 */
class OWOptionalEncapsulation<T> {
    fileprivate var _value: T?

    init(value: T) {
        self._value = value
    }
    
    func value() -> T? {
        return _value
    }
}
