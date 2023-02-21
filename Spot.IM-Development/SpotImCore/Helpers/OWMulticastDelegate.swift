//
//  MulticastDelegates.swift
//  SpotImCore
//
//  Created by Eugene on 13.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

class OWMulticastDelegate<T> {
    private let delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()

    func contains(delegate: T) -> Bool {
        return delegates.contains(delegate as AnyObject)
    }

    func add(delegate: T) {
        if !contains(delegate: delegate) {
            delegates.add(delegate as AnyObject)
        }
    }

    func remove(delegate: T) {
        for oneDelegate in delegates.allObjects.reversed() {
            if oneDelegate === delegate as AnyObject {
                delegates.remove(oneDelegate)
            }
        }
    }

    func invoke(invocation: (T) -> Void) {
        for delegate in delegates.allObjects.reversed() {
            invocation(delegate as! T) // swiftlint:disable:this force_cast
        }
    }
}
