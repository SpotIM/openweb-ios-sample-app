//
//  WeakRef+Generic.swift
//  Spot.IM-Core
//
//  Created by Eugene on 9/2/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

class WeakRef<T> where T: AnyObject {

    private(set) weak var value: T?

    init(value: T?) {
        self.value = value
    }
}
