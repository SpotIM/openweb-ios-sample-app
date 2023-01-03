//
//  RequestInterceptor.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

/// Stores all state associated with a `URLRequest` being adapted.
struct OWNetworkRequestAdapterState {
    /// The `UUID` of the `Request` associated with the `URLRequest` to adapt.
    let requestID: UUID

    /// The `Session` associated with the `URLRequest` to adapt.
    let session: OWNetworkSession
}

// MARK: -

/// A type that can inspect and optionally adapt a `URLRequest` in some manner if necessary.
protocol OWNetworkRequestAdapter {
    /// Inspects and adapts the specified `URLRequest` in some manner and calls the completion handler with the Result.
    ///
    /// - Parameters:
    ///   - urlRequest: The `URLRequest` to adapt.
    ///   - session:    The `Session` that will execute the `URLRequest`.
    ///   - completion: The completion handler that must be called when adaptation is complete.
    func adapt(_ urlRequest: URLRequest, for session: OWNetworkSession, completion: @escaping (Result<URLRequest, Error>) -> Void)

    /// Inspects and adapts the specified `URLRequest` in some manner and calls the completion handler with the Result.
    ///
    /// - Parameters:
    ///   - urlRequest: The `URLRequest` to adapt.
    ///   - state:      The `RequestAdapterState` associated with the `URLRequest`.
    ///   - completion: The completion handler that must be called when adaptation is complete.
    func adapt(_ urlRequest: URLRequest, using state: OWNetworkRequestAdapterState, completion: @escaping (Result<URLRequest, Error>) -> Void)
}

extension OWNetworkRequestAdapter {
    func adapt(_ urlRequest: URLRequest, using state: OWNetworkRequestAdapterState, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        adapt(urlRequest, for: state.session, completion: completion)
    }
}

// MARK: -

/// Outcome of determination whether retry is necessary.
enum OWNetworkRetryResult {
    /// Retry should be attempted immediately.
    case retry
    /// Retry should be attempted after the associated `TimeInterval`.
    case retryWithDelay(TimeInterval)
    /// Do not retry.
    case doNotRetry
    /// Do not retry due to the associated `Error`.
    case doNotRetryWithError(Error)
}

extension OWNetworkRetryResult {
    var retryRequired: Bool {
        switch self {
        case .retry, .retryWithDelay: return true
        default: return false
        }
    }

    var delay: TimeInterval? {
        switch self {
        case let .retryWithDelay(delay): return delay
        default: return nil
        }
    }

    var error: Error? {
        guard case let .doNotRetryWithError(error) = self else { return nil }
        return error
    }
}

/// A type that determines whether a request should be retried after being executed by the specified session manager
/// and encountering an error.
protocol OWNetworkRequestRetrier {
    /// Determines whether the `Request` should be retried by calling the `completion` closure.
    ///
    /// This operation is fully asynchronous. Any amount of time can be taken to determine whether the request needs
    /// to be retried. The one requirement is that the completion closure is called to ensure the request is properly
    /// cleaned up after.
    ///
    /// - Parameters:
    ///   - request:    `Request` that failed due to the provided `Error`.
    ///   - session:    `Session` that produced the `Request`.
    ///   - error:      `Error` encountered while executing the `Request`.
    ///   - completion: Completion closure to be executed when a retry decision has been determined.
    func retry(_ request: OWNetworkRequest, for session: OWNetworkSession, dueTo error: Error, completion: @escaping (OWNetworkRetryResult) -> Void)
}

// MARK: -

/// Type that provides both `RequestAdapter` and `RequestRetrier` functionality.
protocol OWNetworkRequestInterceptor: OWNetworkRequestAdapter, OWNetworkRequestRetrier {}

extension OWNetworkRequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: OWNetworkSession, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        completion(.success(urlRequest))
    }

    func retry(_ request: OWNetworkRequest,
                      for session: OWNetworkSession,
                      dueTo error: Error,
                      completion: @escaping (OWNetworkRetryResult) -> Void) {
        completion(.doNotRetry)
    }
}

/// `RequestAdapter` closure definition.
typealias OWNetworkAdaptHandler = (URLRequest, OWNetworkSession, _ completion: @escaping (Result<URLRequest, Error>) -> Void) -> Void
/// `RequestRetrier` closure definition.
typealias OWNetworkRetryHandler = (OWNetworkRequest, OWNetworkSession, Error, _ completion: @escaping (OWNetworkRetryResult) -> Void) -> Void

// MARK: -

/// Closure-based `RequestAdapter`.
class OWNetworkAdapter: OWNetworkRequestInterceptor {
    private let adaptHandler: OWNetworkAdaptHandler

    /// Creates an instance using the provided closure.
    ///
    /// - Parameter adaptHandler: `AdaptHandler` closure to be executed when handling request adaptation.
    init(_ adaptHandler: @escaping OWNetworkAdaptHandler) {
        self.adaptHandler = adaptHandler
    }

    func adapt(_ urlRequest: URLRequest, for session: OWNetworkSession, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        adaptHandler(urlRequest, session, completion)
    }

    func adapt(_ urlRequest: URLRequest, using state: OWNetworkRequestAdapterState, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        adaptHandler(urlRequest, state.session, completion)
    }
}

extension OWNetworkRequestAdapter where Self == OWNetworkAdapter {
    /// Creates an `Adapter` using the provided `AdaptHandler` closure.
    ///
    /// - Parameter closure: `AdaptHandler` to use to adapt the request.
    /// - Returns:           The `Adapter`.
    static func adapter(using closure: @escaping OWNetworkAdaptHandler) -> OWNetworkAdapter {
        OWNetworkAdapter(closure)
    }
}

// MARK: -

/// Closure-based `RequestRetrier`.
class OWNetworkRetrier: OWNetworkRequestInterceptor {
    private let retryHandler: OWNetworkRetryHandler

    /// Creates an instance using the provided closure.
    ///
    /// - Parameter retryHandler: `RetryHandler` closure to be executed when handling request retry.
    init(_ retryHandler: @escaping OWNetworkRetryHandler) {
        self.retryHandler = retryHandler
    }

    func retry(_ request: OWNetworkRequest,
                    for session: OWNetworkSession,
                    dueTo error: Error,
                    completion: @escaping (OWNetworkRetryResult) -> Void) {
        retryHandler(request, session, error, completion)
    }
}

extension OWNetworkRequestRetrier where Self == OWNetworkRetrier {
    /// Creates a `Retrier` using the provided `RetryHandler` closure.
    ///
    /// - Parameter closure: `RetryHandler` to use to retry the request.
    /// - Returns:           The `Retrier`.
    static func retrier(using closure: @escaping OWNetworkRetryHandler) -> OWNetworkRetrier {
        OWNetworkRetrier(closure)
    }
}

// MARK: -

/// `RequestInterceptor` which can use multiple `RequestAdapter` and `RequestRetrier` values.
class OWNetworkInterceptor: OWNetworkRequestInterceptor {
    /// All `RequestAdapter`s associated with the instance. These adapters will be run until one fails.
    let adapters: [OWNetworkRequestAdapter]
    /// All `RequestRetrier`s associated with the instance. These retriers will be run one at a time until one triggers retry.
    let retriers: [OWNetworkRequestRetrier]

    /// Creates an instance from `AdaptHandler` and `RetryHandler` closures.
    ///
    /// - Parameters:
    ///   - adaptHandler: `AdaptHandler` closure to be used.
    ///   - retryHandler: `RetryHandler` closure to be used.
    init(adaptHandler: @escaping OWNetworkAdaptHandler, retryHandler: @escaping OWNetworkRetryHandler) {
        adapters = [OWNetworkAdapter(adaptHandler)]
        retriers = [OWNetworkRetrier(retryHandler)]
    }

    /// Creates an instance from `RequestAdapter` and `RequestRetrier` values.
    ///
    /// - Parameters:
    ///   - adapter: `RequestAdapter` value to be used.
    ///   - retrier: `RequestRetrier` value to be used.
    init(adapter: OWNetworkRequestAdapter, retrier: OWNetworkRequestRetrier) {
        adapters = [adapter]
        retriers = [retrier]
    }

    /// Creates an instance from the arrays of `RequestAdapter` and `RequestRetrier` values.
    ///
    /// - Parameters:
    ///   - adapters:     `RequestAdapter` values to be used.
    ///   - retriers:     `RequestRetrier` values to be used.
    ///   - interceptors: `RequestInterceptor`s to be used.
    init(adapters: [OWNetworkRequestAdapter] = [], retriers: [OWNetworkRequestRetrier] = [], interceptors: [OWNetworkRequestInterceptor] = []) {
        self.adapters = adapters + interceptors
        self.retriers = retriers + interceptors
    }

    func adapt(_ urlRequest: URLRequest, for session: OWNetworkSession, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        adapt(urlRequest, for: session, using: adapters, completion: completion)
    }

    private func adapt(_ urlRequest: URLRequest,
                       for session: OWNetworkSession,
                       using adapters: [OWNetworkRequestAdapter],
                       completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var pendingAdapters = adapters

        guard !pendingAdapters.isEmpty else { completion(.success(urlRequest)); return }

        let adapter = pendingAdapters.removeFirst()

        adapter.adapt(urlRequest, for: session) { result in
            switch result {
            case let .success(urlRequest):
                self.adapt(urlRequest, for: session, using: pendingAdapters, completion: completion)
            case .failure:
                completion(result)
            }
        }
    }

    func adapt(_ urlRequest: URLRequest, using state: OWNetworkRequestAdapterState, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        adapt(urlRequest, using: state, adapters: adapters, completion: completion)
    }

    private func adapt(_ urlRequest: URLRequest,
                       using state: OWNetworkRequestAdapterState,
                       adapters: [OWNetworkRequestAdapter],
                       completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var pendingAdapters = adapters

        guard !pendingAdapters.isEmpty else { completion(.success(urlRequest)); return }

        let adapter = pendingAdapters.removeFirst()

        adapter.adapt(urlRequest, using: state) { result in
            switch result {
            case let .success(urlRequest):
                self.adapt(urlRequest, using: state, adapters: pendingAdapters, completion: completion)
            case .failure:
                completion(result)
            }
        }
    }

    func retry(_ request: OWNetworkRequest,
                    for session: OWNetworkSession,
                    dueTo error: Error,
                    completion: @escaping (OWNetworkRetryResult) -> Void) {
        retry(request, for: session, dueTo: error, using: retriers, completion: completion)
    }

    private func retry(_ request: OWNetworkRequest,
                       for session: OWNetworkSession,
                       dueTo error: Error,
                       using retriers: [OWNetworkRequestRetrier],
                       completion: @escaping (OWNetworkRetryResult) -> Void) {
        var pendingRetriers = retriers

        guard !pendingRetriers.isEmpty else { completion(.doNotRetry); return }

        let retrier = pendingRetriers.removeFirst()

        retrier.retry(request, for: session, dueTo: error) { result in
            switch result {
            case .retry, .retryWithDelay, .doNotRetryWithError:
                completion(result)
            case .doNotRetry:
                // Only continue to the next retrier if retry was not triggered and no error was encountered
                self.retry(request, for: session, dueTo: error, using: pendingRetriers, completion: completion)
            }
        }
    }
}

extension OWNetworkRequestInterceptor where Self == OWNetworkInterceptor {
    /// Creates an `Interceptor` using the provided `AdaptHandler` and `RetryHandler` closures.
    ///
    /// - Parameters:
    ///   - adapter: `AdapterHandler`to use to adapt the request.
    ///   - retrier: `RetryHandler` to use to retry the request.
    /// - Returns:   The `Interceptor`.
    static func interceptor(adapter: @escaping OWNetworkAdaptHandler, retrier: @escaping OWNetworkRetryHandler) -> OWNetworkInterceptor {
        OWNetworkInterceptor(adaptHandler: adapter, retryHandler: retrier)
    }

    /// Creates an `Interceptor` using the provided `RequestAdapter` and `RequestRetrier` instances.
    /// - Parameters:
    ///   - adapter: `RequestAdapter` to use to adapt the request
    ///   - retrier: `RequestRetrier` to use to retry the request.
    /// - Returns:   The `Interceptor`.
    static func interceptor(adapter: OWNetworkRequestAdapter, retrier: OWNetworkRequestRetrier) -> OWNetworkInterceptor {
        OWNetworkInterceptor(adapter: adapter, retrier: retrier)
    }

    /// Creates an `Interceptor` using the provided `RequestAdapter`s, `RequestRetrier`s, and `RequestInterceptor`s.
    /// - Parameters:
    ///   - adapters:     `RequestAdapter`s to use to adapt the request. These adapters will be run until one fails.
    ///   - retriers:     `RequestRetrier`s to use to retry the request. These retriers will be run one at a time until
    ///                   a retry is triggered.
    ///   - interceptors: `RequestInterceptor`s to use to intercept the request.
    /// - Returns:        The `Interceptor`.
    static func interceptor(adapters: [OWNetworkRequestAdapter] = [],
                                   retriers: [OWNetworkRequestRetrier] = [],
                                   interceptors: [OWNetworkRequestInterceptor] = []) -> OWNetworkInterceptor {
        OWNetworkInterceptor(adapters: adapters, retriers: retriers, interceptors: interceptors)
    }
}
