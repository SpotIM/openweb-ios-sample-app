//
//  RedirectHandler.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

/// A type that handles how an HTTP redirect response from a remote server should be redirected to the new request.
protocol OWNetworkRedirectHandler {
    /// Determines how the HTTP redirect response should be redirected to the new request.
    ///
    /// The `completion` closure should be passed one of three possible options:
    ///
    ///   1. The new request specified by the redirect (this is the most common use case).
    ///   2. A modified version of the new request (you may want to route it somewhere else).
    ///   3. A `nil` value to deny the redirect request and return the body of the redirect response.
    ///
    /// - Parameters:
    ///   - task:       The `URLSessionTask` whose request resulted in a redirect.
    ///   - request:    The `URLRequest` to the new location specified by the redirect response.
    ///   - response:   The `HTTPURLResponse` containing the server's response to the original request.
    ///   - completion: The closure to execute containing the new `URLRequest`, a modified `URLRequest`, or `nil`.
    func task(_ task: URLSessionTask,
              willBeRedirectedTo request: URLRequest,
              for response: HTTPURLResponse,
              completion: @escaping (URLRequest?) -> Void)
}

// MARK: -

/// `Redirector` is a convenience `RedirectHandler` making it easy to follow, not follow, or modify a redirect.
struct OWNetworkRedirector {
    /// Defines the behavior of the `Redirector` type.
    enum Behavior {
        /// Follow the redirect as defined in the response.
        case follow
        /// Do not follow the redirect defined in the response.
        case doNotFollow
        /// Modify the redirect request defined in the response.
        case modify((URLSessionTask, URLRequest, HTTPURLResponse) -> URLRequest?)
    }

    /// Returns a `Redirector` with a `.follow` `Behavior`.
    static let follow = OWNetworkRedirector(behavior: .follow)
    /// Returns a `Redirector` with a `.doNotFollow` `Behavior`.
    static let doNotFollow = OWNetworkRedirector(behavior: .doNotFollow)

    /// The `Behavior` of the `Redirector`.
    let behavior: Behavior

    /// Creates a `Redirector` instance from the `Behavior`.
    ///
    /// - Parameter behavior: The `Behavior`.
    init(behavior: Behavior) {
        self.behavior = behavior
    }
}

// MARK: -

extension OWNetworkRedirector: OWNetworkRedirectHandler {
    func task(_ task: URLSessionTask,
              willBeRedirectedTo request: URLRequest,
              for response: HTTPURLResponse,
              completion: @escaping (URLRequest?) -> Void) {
        switch behavior {
        case .follow:
            completion(request)
        case .doNotFollow:
            completion(nil)
        case let .modify(closure):
            let request = closure(task, request, response)
            completion(request)
        }
    }
}

extension OWNetworkRedirectHandler where Self == OWNetworkRedirector {
    /// Provides a `Redirector` which follows redirects. Equivalent to `Redirector.follow`.
    static var follow: OWNetworkRedirector { .follow }

    /// Provides a `Redirector` which does not follow redirects. Equivalent to `Redirector.doNotFollow`.
    static var doNotFollow: OWNetworkRedirector { .doNotFollow }

    /// Creates a `Redirector` which modifies the redirected `URLRequest` using the provided closure.
    ///
    /// - Parameter closure: Closure used to modify the redirect.
    /// - Returns:           The `Redirector`.
    static func modify(using closure: @escaping (URLSessionTask, URLRequest, HTTPURLResponse) -> URLRequest?) -> OWNetworkRedirector {
        OWNetworkRedirector(behavior: .modify(closure))
    }
}
