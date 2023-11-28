//
//  OWNetworkAuthorizationRecoveryInterceptor.swift
//  SpotImCore
//
//  Created by Alon Haiut on 16/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

class OWNetworkAuthorizationRecoveryInterceptor: OWNetworkRequestInterceptor {
    fileprivate let retryLimit: Int
    fileprivate let servicesProvider: OWSharedServicesProviding

    init(retryLimit: Int = 2, servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.retryLimit = retryLimit
        self.servicesProvider = servicesProvider
    }

    func adapt(_ urlRequest: URLRequest, for session: OWNetworkSession, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest

        // Update Authorization - required because retry requests with old `Authorization` will need to be updated with new `Authorization` when called for a retry
        let authenticationManager = servicesProvider.authenticationManager()
        if let authorization = authenticationManager.networkCredentials.authorization, !authorization.isEmpty {
            request.setValue(authorization, forHTTPHeaderField: OWHTTPHeaderType.authorization.rawValue)
        }

        completion(.success(request))
    }

    func retry(_ request: OWNetworkRequest, for session: OWNetworkSession, dueTo error: Error, completion: @escaping (OWNetworkRetryResult) -> Void) {
        let requestURL = request.request?.url?.description ?? ""

        guard request.retryCount < retryLimit else {
            let log = "Request: \(requestURL) exceed max retry limit \(retryLimit)"
            servicesProvider.logger().log(level: .medium, log)
            completion(.doNotRetry)
            return
        }

        if let errorCode = error.asOWNetworkError?.responseCode,
           errorCode == OWNetworkStatusCode.authorizationErrorCode {
            // Authorization error (i.e code 403)
            recoverFromAuthorizationError(completion: completion, requestURLPath: requestURL)

        } else {
            // General error, just retry
            let log = "Reuest: \(requestURL) going to retry"
            servicesProvider.logger().log(level: .verbose, log)
            completion(.retry)
        }
    }
}

fileprivate extension OWNetworkAuthorizationRecoveryInterceptor {
    func recoverFromAuthorizationError(completion: @escaping (OWNetworkRetryResult) -> Void, requestURLPath: String) {
        let authorizationRecoveryService = servicesProvider.authorizationRecoveryService()

        _ = authorizationRecoveryService.recoverAuthorization()
            .take(1) // No need to dispose
            .subscribe(onNext: { [weak self] _ in
                let log = "Request: \(requestURLPath) going to retry after generating a new authorization token after network 403 error code"
                self?.servicesProvider.logger().log(level: .verbose, log)
                // Will succeed because we re-generate a new guest user session regardless of the silent SSO
                // 'adapt' function will inject the new auth token
                completion(.retry)
            }, onError: { [weak self] _ in
                let log = "Failed to get recover after clearing authorization header to try recover from 403 error code.\nRequest: \(requestURLPath) failed because of that"
                self?.servicesProvider.logger().log(level: .error, log)
                completion(.doNotRetry)
            })
    }
}

