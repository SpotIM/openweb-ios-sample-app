//
//  OWNetworkURLConvertible+URLRequestConvertible.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//
import Foundation

/// Types adopting the `URLConvertible` protocol can be used to construct `URL`s, which can then be used to construct
/// `URLRequests`.
protocol OWNetworkURLConvertible {
    /// Returns a `URL` from the conforming instance or throws.
    ///
    /// - Returns: The `URL` created from the instance.
    /// - Throws:  Any error thrown while creating the `URL`.
    func asURL() throws -> URL
}

extension String: OWNetworkURLConvertible {
    /// Returns a `URL` if `self` can be used to initialize a `URL` instance, otherwise throws.
    ///
    /// - Returns: The `URL` initialized with `self`.
    /// - Throws:  An `AFError.invalidURL` instance.
    func asURL() throws -> URL {
        guard let url = URL(string: self) else { throw OWNetworkError.invalidURL(url: self) }

        return url
    }
}

extension URL: OWNetworkURLConvertible {
    /// Returns `self`.
    func asURL() throws -> URL { self }
}

extension URLComponents: OWNetworkURLConvertible {
    /// Returns a `URL` if the `self`'s `url` is not nil, otherwise throws.
    ///
    /// - Returns: The `URL` from the `url` property.
    /// - Throws:  An `AFError.invalidURL` instance.
    func asURL() throws -> URL {
        guard let url = url else { throw OWNetworkError.invalidURL(url: self) }

        return url
    }
}

// MARK: -

/// Types adopting the `URLRequestConvertible` protocol can be used to safely construct `URLRequest`s.
protocol OWNetworkURLRequestConvertible {
    /// Returns a `URLRequest` or throws if an `Error` was encountered.
    ///
    /// - Returns: A `URLRequest`.
    /// - Throws:  Any error thrown while constructing the `URLRequest`.
    func asURLRequest() throws -> URLRequest
}

extension OWNetworkURLRequestConvertible {
    /// The `URLRequest` returned by discarding any `Error` encountered.
    var urlRequest: URLRequest? { try? asURLRequest() }
}

extension URLRequest: OWNetworkURLRequestConvertible {
    /// Returns `self`.
    func asURLRequest() throws -> URLRequest { self }
}

// MARK: -

extension URLRequest {
    /// Creates an instance with the specified `url`, `method`, and `headers`.
    ///
    /// - Parameters:
    ///   - url:     The `URLConvertible` value.
    ///   - method:  The `HTTPMethod`.
    ///   - headers: The `HTTPHeaders`, `nil` by default.
    /// - Throws:    Any error thrown while converting the `URLConvertible` to a `URL`.
    init(url: OWNetworkURLConvertible, method: HTTPMethod, headers: HTTPHeaders? = nil) throws {
        let url = try url.asURL()

        self.init(url: url)

        httpMethod = method.rawValue
        allHTTPHeaderFields = headers?.dictionary
    }
}
