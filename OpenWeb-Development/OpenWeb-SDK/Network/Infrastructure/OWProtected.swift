//
//  Protected.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 20/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

extension OWLock {
    /// Executes a closure returning a value while acquiring the lock.
    ///
    /// - Parameter closure: The closure to run.
    ///
    /// - Returns:           The value the closure generated.
    func around<T>(_ closure: () throws -> T) rethrows -> T {
        lock(); defer { unlock() }
        return try closure()
    }

    /// Execute a closure while acquiring the lock.
    ///
    /// - Parameter closure: The closure to run.
    func around(_ closure: () throws -> Void) rethrows {
        lock(); defer { unlock() }
        try closure()
    }
}

/// A thread-safe wrapper around a value.
@propertyWrapper
@dynamicMemberLookup
class OWProtected<T> {
    private let lock = OWUnfairLock()
    private var value: T

    init(_ value: T) {
        self.value = value
    }

    /// The contained value. Unsafe for anything more than direct read or write.
    var wrappedValue: T {
        get { lock.around { value } }
        set { lock.around { value = newValue } }
    }

    var projectedValue: OWProtected<T> { self }

    init(wrappedValue: T) {
        value = wrappedValue
    }

    /// Synchronously read or transform the contained value.
    ///
    /// - Parameter closure: The closure to execute.
    ///
    /// - Returns:           The return value of the closure passed.
    func read<U>(_ closure: (T) throws -> U) rethrows -> U {
        try lock.around { try closure(self.value) }
    }

    /// Synchronously modify the protected value.
    ///
    /// - Parameter closure: The closure to execute.
    ///
    /// - Returns:           The modified value.
    @discardableResult
    func write<U>(_ closure: (inout T) throws -> U) rethrows -> U {
        try lock.around { try closure(&self.value) }
    }

    subscript<Property>(dynamicMember keyPath: WritableKeyPath<T, Property>) -> Property {
        get { lock.around { value[keyPath: keyPath] } }
        set { lock.around { value[keyPath: keyPath] = newValue } }
    }

    subscript<Property>(dynamicMember keyPath: KeyPath<T, Property>) -> Property {
        lock.around { value[keyPath: keyPath] }
    }
}

extension OWProtected where T == OWNetworkRequest.MutableState {
    /// Attempts to transition to the passed `State`.
    ///
    /// - Parameter state: The `State` to attempt transition to.
    ///
    /// - Returns:         Whether the transition occurred.
    func attemptToTransitionTo(_ state: OWNetworkRequest.State) -> Bool {
        lock.around {
            guard value.state.canTransitionTo(state) else { return false }

            value.state = state

            return true
        }
    }

    /// Perform a closure while locked with the provided `Request.State`.
    ///
    /// - Parameter perform: The closure to perform while locked.
    func withState(perform: (OWNetworkRequest.State) -> Void) {
        lock.around { perform(value.state) }
    }
}
