//
//  HTTPMethod.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

/// Type representing HTTP methods. Raw `String` value is stored and compared case-sensitively, so
/// `HTTPMethod.get != HTTPMethod(rawValue: "get")`.
///
/// See https://tools.ietf.org/html/rfc7231#section-4.3
struct OWNetworkHTTPMethod: RawRepresentable, Equatable, Hashable {
    /// `CONNECT` method.
    static let connect = OWNetworkHTTPMethod(rawValue: "CONNECT")
    /// `DELETE` method.
    static let delete = OWNetworkHTTPMethod(rawValue: "DELETE")
    /// `GET` method.
    static let get = OWNetworkHTTPMethod(rawValue: "GET")
    /// `HEAD` method.
    static let head = OWNetworkHTTPMethod(rawValue: "HEAD")
    /// `OPTIONS` method.
    static let options = OWNetworkHTTPMethod(rawValue: "OPTIONS")
    /// `PATCH` method.
    static let patch = OWNetworkHTTPMethod(rawValue: "PATCH")
    /// `POST` method.
    static let post = OWNetworkHTTPMethod(rawValue: "POST")
    /// `PUT` method.
    static let put = OWNetworkHTTPMethod(rawValue: "PUT")
    /// `QUERY` method.
    static let query = OWNetworkHTTPMethod(rawValue: "QUERY")
    /// `TRACE` method.
    static let trace = OWNetworkHTTPMethod(rawValue: "TRACE")

    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}
