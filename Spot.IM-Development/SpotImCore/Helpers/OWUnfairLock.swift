//
//  OWUnfairLock.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

/*
 A nice way to use the lock inside a function will be to create a "lock" variable as a class member in which this function located.
 Then inside the function write the following at the beginning.
 `self.lock.lock(); defer { self.lock.unlock() }`
 */

protocol OWLock {
    func lock()
    func unlock()
}

class OWUnfairLock: OWLock {
    private let unfairLock: os_unfair_lock_t

    init() {
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
    }

    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }

    func lock() {
        os_unfair_lock_lock(unfairLock)
    }

    func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }
}
