//
//  SPInternalAuthProvider.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 25/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

internal protocol SPInternalAuthProvider {
    static func login(completion: @escaping (String?, Error?) -> Void)
}

internal final class SPDefaultInternalAuthProvider: SPInternalAuthProvider {
    
    static internal func login(completion: @escaping (String?, Error?) -> Void) {
        let spRequest = SPInternalAuthRequests.guest
        guard let spotKey = SPClientSettings.spotKey else {
            let message = NSLocalizedString("Please provide Spot Key",
                                            bundle: Bundle.spot,
                                            comment: "Spot Key not set by client")
            completion(nil, SPNetworkError.custom(message))
            return
        }

        var headers = HTTPHeaders.unauthorized(with: spotKey, postId: "default")
        if let token = SPUserSessionHolder.session.token {
            headers["Authorization"] = token
        }
        // TODO: (Fedin) move Alamofire.request elsewhere
        Alamofire.request(spRequest.url,
                          method: spRequest.method,
                          parameters: nil,
                          encoding: APIConstants.encoding,
                          headers: headers)
            .validate()
            .responseData { response in
                let token = response.response?.allHeaderFields.authorizationHeader
                var error: Error?
                if response.error != nil {
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: nil,
                        errorData: response.data,
                        errorMessage: error!.localizedDescription
                    )
                    SPDefaultFailureReporter().sendFailureReport(rawReport)
                    
                    error = SPNetworkError.default
                }
                
                let result: Result<SPUser> = defaultDecoder.decodeResponse(from: response)
                if case let .success(user) = result {
                    SPUserSessionHolder.updateSessionUser(user: user)
                }
                completion(token, error)
            }
    }
}
