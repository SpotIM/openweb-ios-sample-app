//
//  Result.swift
//  SpotImCore
//
//  Created by Eugene on 08.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

public enum OWResult<T> {

    case success(T)
    case failure(Error)

    public var value: T? {
        switch self {
        case .success(let result): return result
        case .failure: return nil
        }
    }

    public var error: Error? {
        switch self {
        case .success: return nil
        case .failure(let error): return error
        }
    }
}

extension OWResult {

    @discardableResult
    public func map<U>(_ function: (T) -> U) -> OWResult<U> {
        switch self {
        case .success(let value): return .success(function(value))
        case .failure(let error): return .failure(error)
        }
    }

    @discardableResult
    public func map<U>(_ function: () -> U) -> OWResult<U> {
        switch self {
        case .success: return .success(function())
        case .failure(let error): return .failure(error)
        }
    }

    @discardableResult
    public func next<U>(_ function: (T) -> OWResult<U>) -> OWResult<U> {
        switch self {
        case .success(let value): return function(value)
        case .failure(let error): return .failure(error)
        }
    }

    @discardableResult
    public func next<U>(_ function: () -> OWResult<U>) -> OWResult<U> {
        switch self {
        case .success: return function()
        case .failure(let error): return .failure(error)
        }
    }

    @discardableResult
    public func onError(_ function: (Error) -> Error) -> OWResult<T> {
        switch self {
        case .success(let value): return .success(value)
        case .failure(let error): return .failure(function(error))
        }
    }

    @discardableResult
    public func require() -> T {
        switch self {
        case .success(let value): return value
        case .failure(let error): fatalError("Value is required: \(error)")
        }
    }

}
