//
//  OWNetworkInterceptor.swift
//  SpotImCore
//
//  Created by Alon Haiut on 29/05/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

class OWNetworkInterceptorLayer: OWNetworkRequestInterceptor {
    fileprivate let retryLimit: Int
    fileprivate let servicesProvider: OWSharedServicesProviding
    
    init(retryLimit: Int = 2, servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.retryLimit = retryLimit
        self.servicesProvider = servicesProvider
    }
    
    func adapt(_ urlRequest: URLRequest, for session: OWNetworkSession, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        
        // Update token - required because retry requests with old token will need to be updated with new token when called for a retry
        if let token = SPUserSessionHolder.session.token, !token.isEmpty {
            request.setValue(token, forHTTPHeaderField: APIHeadersConstants.authorization)
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
            errorCode == APIErrorCodes.authorizationErrorCode  {
            // Authorization error (i.e code 403)
              
            // Get new user session and reset the old one
            // Also check if we should renew SSO after the process
            let isUserRegistered = SPUserSessionHolder.isRegister()
            let isSSO = SPConfigsDataSource.appConfig?.initialization?.ssoEnabled ?? false
            let shouldRenewSSO = isUserRegistered && isSSO
            let userId = SPUserSessionHolder.session.user?.userId ?? ""
            SPUserSessionHolder.resetUserSession()
            
            // Due to bad architecture it is not possible to dependency injection the authProvider in the class initializer
            _ = SpotIm.authProvider
                .getUser()
                .take(1) // No need to dispose
                .subscribe(onNext: { [weak self] _ in
                    let log = "Request: \(requestURL) going to retry after generating a new authorization token after network 403 error code"
                    self?.servicesProvider.logger().log(level: .verbose, log)
                    
                    if shouldRenewSSO {
                        // Will renew SSO with publishers API if a user was logged in before
                        self?.servicesProvider.logger().log(level: .verbose, "Renew SSO triggered after network 403 error code")
                        SpotIm.authProvider.renewSSOPublish.onNext(userId)
                    }
                    
                    // Will succeed because we re-generate a new guest user session regardless of the silent SSO
                    // 'adapt' function will inject the new auth token
                    completion(.retry)
                }, onError: { [weak self] _ in
                    let log = "Failed to get `user/data` after clearing authorization header for recovering from 403 error code.\nRequest: \(requestURL) failed because of that"
                    self?.servicesProvider.logger().log(level: .error, log)
                    completion(.doNotRetry)
                })
        } else {
            // General error, just retry
            let log = "Reuest: \(requestURL) going to retry"
            servicesProvider.logger().log(level: .verbose, log)
            completion(.retry)
        }
    }
}
