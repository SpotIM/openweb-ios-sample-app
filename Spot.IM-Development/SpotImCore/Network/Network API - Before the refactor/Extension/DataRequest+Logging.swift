//
//  URLRequest_cUrl.swift
//  SpotImCore
//
//  Created by Rotem Itzhak on 31/12/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal extension OWNetworkDataRequest {

    @discardableResult
    func log(level: OWLogLevel = .medium) -> Self {
        #if DEBUG
        self.logRequest(level: level)
        return self.logResponse(level: level)
        #else
        return self
        #endif
    }

    @discardableResult
    private func logRequest(level: OWLogLevel = .medium) -> Self {
        guard level != .none else {
            return self
        }
        return self.cURLDescription { _ in
            guard
                let method = self.request?.httpMethod,
                let url = self.request?.url else {
                return
            }

            var message = "[REQUEST] \(method) \(url)"

            if level == .medium {
                if let criticalHeaders = self.request?.allHTTPHeaderFields?.filter({ (key: AnyHashable, _: Any) -> Bool in
                    guard let keyString = key as? String else { return false }

                    return keyString == "x-spot-id" || keyString == "x-post-id"
                }) {
                    for header in criticalHeaders {
                        message += "\n\(header.key): \(header.value)"
                    }
                }
            }

            if level == .verbose {
                if let headers = self.request?.allHTTPHeaderFields {
                    for header in headers {
                        message += "\n\(header.key): \(header.value)"
                    }
                }
                if let data = self.request?.httpBody,
                    let body = String(data: data, encoding: .utf8) {
                    message += "\n\(body)"
                }
            }

            if level == .verbose || level == .medium {
                if let data = self.request?.httpBody,
                    let body = String(data: data, encoding: .utf8) {
                    message += "\n\(body)"
                }
            }

            OWSharedServicesProvider.shared.logger().log(level: level, message)
        }
    }

    @discardableResult
    private func logResponse(level: OWLogLevel = .medium) -> Self {
        guard level != .none else {
            return self
        }

        return self.response(completionHandler: {
            guard
                let method = $0.request?.httpMethod,
                let url = $0.request?.url else {
                return
            }

            var message = "[RESPONSE] \(method) \($0.response?.statusCode ?? -1) \(url) \(String(format: "%.3fms", ($0.metrics?.taskInterval.duration ?? 0) * 1000))"

            if let err = $0.error?.localizedDescription {
                message += " [!] \(err)"
            }

            if level == .medium {
                if let criticalHeaders = $0.response?.allHeaderFields.filter({ (key: AnyHashable, _: Any) -> Bool in
                    guard let keyString = key as? String else { return false }

                    return keyString == "x-spot-id" || keyString == "x-post-id"
                }) {
                    for header in criticalHeaders {
                        message += "\n\(header.key): \(header.value)"
                    }
                }
            }

            if level == .verbose {
                if let headers = $0.response?.allHeaderFields {
                    for header in headers {
                        message += "\n\(header.key): \(header.value)"
                    }
                }
            }

            if level == .verbose || level == .medium {
                if let data = $0.data,
                    let body = String(data: data, encoding: .utf8) {
                    if body.count > 0 {
                        message += "\n\(body)"
                    }
                }
            }

            OWSharedServicesProvider.shared.logger().log(level: level, message)
        })
    }
}
