//
//  OWNetworkInterceptor.swift
//  SpotImCore
//
//  Created by Alon Haiut on 29/05/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

class OWNetworkInterceptor: RequestInterceptor {
    fileprivate let retryLimit: Int
    fileprivate let servicesProvider: OWSharedServicesProviding
    
    init(retryLimit: Int = 2, servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.retryLimit = retryLimit
        self.servicesProvider = servicesProvider
    }
    
    // Adapt should not change as we inject headers in a different place
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        let requestURL = request.request?.url?.description ?? ""
        
        guard request.retryCount < retryLimit else {
            let log = "Reuest: \(requestURL) exceed max retry limit \(retryLimit)"
            servicesProvider.logger().log(level: .medium, log)
            completion(.doNotRetry)
            return
        }
        
        guard let errorCode = error.asAFError?.responseCode,
              errorCode == APIErrorCodes.authorizationErrorCode else {
                  let log = "Reuest: \(requestURL) going to retry"
                  servicesProvider.logger().log(level: .verbose, log)
                  completion(.retry)
                  return
              }
        
        // Get new user session and authorization token
        // Will renew SSO with publishers API if a user was logged in before
        // Due to bad architecture it is not possible to dependency injection the authProvider in the class initializer
        _ = SpotIm.authProvider
            .getUser()
            .take(1) // No need to dispose
            .subscribe(onNext: { [weak self] _ in
                let log = "Reuest: \(requestURL) going to retry after generating a new authorization token"
                self?.servicesProvider.logger().log(level: .verbose, log)
                completion(.retry)
            })
    }
}
