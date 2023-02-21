//
//  ParameterEncoder.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

/// A type that can encode any `Encodable` type into a `URLRequest`.
protocol OWNetworkParameterEncoder {
    /// Encode the provided `Encodable` parameters into `request`.
    ///
    /// - Parameters:
    ///   - parameters: The `Encodable` parameter value.
    ///   - request:    The `URLRequest` into which to encode the parameters.
    ///
    /// - Returns:      A `URLRequest` with the result of the encoding.
    /// - Throws:       An `Error` when encoding fails. For OWNetwork provided encoders, this will be an instance of
    ///                 `AFError.parameterEncoderFailed` with an associated `ParameterEncoderFailureReason`.
    func encode<Parameters: Encodable>(_ parameters: Parameters?, into request: URLRequest) throws -> URLRequest
}

/// A `ParameterEncoder` that encodes types as JSON body data.
///
/// If no `Content-Type` header is already set on the provided `URLRequest`s, it's set to `application/json`.
class OWNetworkJSONParameterEncoder: OWNetworkParameterEncoder {
    /// Returns an encoder with default parameters.
    static var `default`: OWNetworkJSONParameterEncoder { OWNetworkJSONParameterEncoder() }

    /// Returns an encoder with `JSONEncoder.outputFormatting` set to `.prettyPrinted`.
    static var prettyPrinted: OWNetworkJSONParameterEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        return OWNetworkJSONParameterEncoder(encoder: encoder)
    }

    /// Returns an encoder with `JSONEncoder.outputFormatting` set to `.sortedKeys`.
    static var sortedKeys: OWNetworkJSONParameterEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        return OWNetworkJSONParameterEncoder(encoder: encoder)
    }

    /// `JSONEncoder` used to encode parameters.
    let encoder: JSONEncoder

    /// Creates an instance with the provided `JSONEncoder`.
    ///
    /// - Parameter encoder: The `JSONEncoder`. `JSONEncoder()` by default.
    init(encoder: JSONEncoder = JSONEncoder()) {
        self.encoder = encoder
    }

    func encode<Parameters: Encodable>(_ parameters: Parameters?,
                                       into request: URLRequest) throws -> URLRequest {
        guard let parameters = parameters else { return request }

        var request = request

        do {
            let data = try encoder.encode(parameters)
            request.httpBody = data
            if request.headers["Content-Type"] == nil {
                request.headers.update(.contentType("application/json"))
            }
        } catch {
            throw OWNetworkError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }

        return request
    }
}

extension OWNetworkParameterEncoder where Self == OWNetworkJSONParameterEncoder {
    /// Provides a default `JSONParameterEncoder` instance.
    static var json: OWNetworkJSONParameterEncoder { OWNetworkJSONParameterEncoder() }

    /// Creates a `JSONParameterEncoder` using the provided `JSONEncoder`.
    ///
    /// - Parameter encoder: `JSONEncoder` used to encode parameters. `JSONEncoder()` by default.
    /// - Returns:           The `JSONParameterEncoder`.
    static func json(encoder: JSONEncoder = JSONEncoder()) -> OWNetworkJSONParameterEncoder {
        OWNetworkJSONParameterEncoder(encoder: encoder)
    }
}

/// A `ParameterEncoder` that encodes types as URL-encoded query strings to be set on the URL or as body data, depending
/// on the `Destination` set.
///
/// If no `Content-Type` header is already set on the provided `URLRequest`s, it will be set to
/// `application/x-www-form-urlencoded; charset=utf-8`.
///
/// Encoding behavior can be customized by passing an instance of `URLEncodedFormEncoder` to the initializer.
class OWNetworkURLEncodedFormParameterEncoder: OWNetworkParameterEncoder {
    /// Defines where the URL-encoded string should be set for each `URLRequest`.
    enum Destination {
        /// Applies the encoded query string to any existing query string for `.get`, `.head`, and `.delete` request.
        /// Sets it to the `httpBody` for all other methods.
        case methodDependent
        /// Applies the encoded query string to any existing query string from the `URLRequest`.
        case queryString
        /// Applies the encoded query string to the `httpBody` of the `URLRequest`.
        case httpBody

        /// Determines whether the URL-encoded string should be applied to the `URLRequest`'s `url`.
        ///
        /// - Parameter method: The `HTTPMethod`.
        ///
        /// - Returns:          Whether the URL-encoded string should be applied to a `URL`.
        func encodesParametersInURL(for method: OWNetworkHTTPMethod) -> Bool {
            switch self {
            case .methodDependent: return [.get, .head, .delete].contains(method)
            case .queryString: return true
            case .httpBody: return false
            }
        }
    }

    /// Returns an encoder with default parameters.
    static var `default`: OWNetworkURLEncodedFormParameterEncoder { OWNetworkURLEncodedFormParameterEncoder() }

    /// The `URLEncodedFormEncoder` to use.
    let encoder: OWNetworkURLEncodedFormEncoder

    /// The `Destination` for the URL-encoded string.
    let destination: Destination

    /// Creates an instance with the provided `URLEncodedFormEncoder` instance and `Destination` value.
    ///
    /// - Parameters:
    ///   - encoder:     The `URLEncodedFormEncoder`. `URLEncodedFormEncoder()` by default.
    ///   - destination: The `Destination`. `.methodDependent` by default.
    init(encoder: OWNetworkURLEncodedFormEncoder = OWNetworkURLEncodedFormEncoder(), destination: Destination = .methodDependent) {
        self.encoder = encoder
        self.destination = destination
    }

    func encode<Parameters: Encodable>(_ parameters: Parameters?,
                                       into request: URLRequest) throws -> URLRequest {
        guard let parameters = parameters else { return request }

        var request = request

        guard let url = request.url else {
            throw OWNetworkError.parameterEncoderFailed(reason: .missingRequiredComponent(.url))
        }

        guard let method = request.method else {
            let rawValue = request.method?.rawValue ?? "nil"
            throw OWNetworkError.parameterEncoderFailed(reason: .missingRequiredComponent(.httpMethod(rawValue: rawValue)))
        }

        if destination.encodesParametersInURL(for: method),
           var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            let query: String = try Result<String, Error> { try encoder.encode(parameters) }
                .mapError { OWNetworkError.parameterEncoderFailed(reason: .encoderFailed(error: $0)) }.get()
            let newQueryString = [components.percentEncodedQuery, query].compactMap { $0 }.joinedWithAmpersands()
            components.percentEncodedQuery = newQueryString.isEmpty ? nil : newQueryString

            guard let newURL = components.url else {
                throw OWNetworkError.parameterEncoderFailed(reason: .missingRequiredComponent(.url))
            }

            request.url = newURL
        } else {
            if request.headers["Content-Type"] == nil {
                request.headers.update(.contentType("application/x-www-form-urlencoded; charset=utf-8"))
            }

            request.httpBody = try Result<Data, Error> { try encoder.encode(parameters) }
                .mapError { OWNetworkError.parameterEncoderFailed(reason: .encoderFailed(error: $0)) }.get()
        }

        return request
    }
}

extension OWNetworkParameterEncoder where Self == OWNetworkURLEncodedFormParameterEncoder {
    /// Provides a default `URLEncodedFormParameterEncoder` instance.
    static var urlEncodedForm: OWNetworkURLEncodedFormParameterEncoder { OWNetworkURLEncodedFormParameterEncoder() }

    /// Creates a `URLEncodedFormParameterEncoder` with the provided encoder and destination.
    ///
    /// - Parameters:
    ///   - encoder:     `URLEncodedFormEncoder` used to encode the parameters. `URLEncodedFormEncoder()` by default.
    ///   - destination: `Destination` to which to encode the parameters. `.methodDependent` by default.
    /// - Returns:       The `URLEncodedFormParameterEncoder`.
    static func urlEncodedForm(encoder: OWNetworkURLEncodedFormEncoder = OWNetworkURLEncodedFormEncoder(),
                               destination: OWNetworkURLEncodedFormParameterEncoder.Destination = .methodDependent) -> OWNetworkURLEncodedFormParameterEncoder {
        OWNetworkURLEncodedFormParameterEncoder(encoder: encoder, destination: destination)
    }
}
