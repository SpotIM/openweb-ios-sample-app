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
    func login(completion: @escaping (String?, Error?) -> Void)
}

internal final class SPDefaultInternalAuthProvider: NetworkDataProvider, SPInternalAuthProvider {
    
    internal func login(completion: @escaping (String?, Error?) -> Void) {
        let spRequest = SPInternalAuthRequests.guest
        guard let spotKey = SPClientSettings.main.spotKey else {
            let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
            completion(nil, SPNetworkError.custom(message))
            return
        }

        var headers = HTTPHeaders.basic(with: spotKey, postId: "default")
        if let token = SPUserSessionHolder.session.token {
            headers["Authorization"] = token
        }
        
        manager.execute(
            request: spRequest,
            parser: DecodableParser<SPUser>(),
            headers: headers
        ) { result, response in
            let token = response.response?.allHeaderFields.authorizationHeader
            switch result {
            case .success(let user):
                SPUserSessionHolder.updateSessionUser(user: user)
                completion(token, nil)
                
            case .failure(let error):
                let rawReport = RawReportModel(
                    url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                    parameters: nil,
                    errorData: response.data,
                    errorMessage: error.localizedDescription
                )
                SPDefaultFailureReporter().sendFailureReport(rawReport)
                completion(token, error)
            }
        }
    }
}
