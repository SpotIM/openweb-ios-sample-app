//
//  SPInternalAuthProvider.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 25/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

internal protocol SPInternalAuthProvider {
    func login(completion: @escaping (String?, Error?) -> Void)
    func logout() -> Promise<Void>
    func user() -> Promise<SPUser>
}

internal final class SPDefaultInternalAuthProvider: NetworkDataProvider, SPInternalAuthProvider {
    
    internal func login(completion: @escaping (String?, Error?) -> Void) {
        guard let spotKey = SPClientSettings.main.spotKey else {
            let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
            completion(nil, SPNetworkError.custom(message))
            return
        }
        
        let spRequest = SPInternalAuthRequests.guest

        var headers = HTTPHeaders.basic(with: spotKey)
        if let token = SPUserSessionHolder.session.token {
            headers[APIHeadersConstants.authorization] = token
        }

        manager.execute(
            request: spRequest,
            parser: OWDecodableParser<SPUser>(),
            headers: headers
        ) { result, response in
            let token = response.response?.allHeaderFields.authorizationHeader ?? SPUserSessionHolder.session.token
            if token == nil {
                let rawReport = RawReportModel(
                    url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                    parameters: nil,
                    errorData: response.data,
                    errorMessage: "Authorization header empty"
                )
                SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
                completion(nil, SPNetworkError.default)
            }
            
            switch result {
                case .success(let user):
                    SPUserSessionHolder.updateSession(with: response.response)
                    SPUserSessionHolder.updateSessionUser(user: user)
                    completion(token, nil)
                    
                case .failure(let error):
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: nil,
                        errorData: response.data,
                        errorMessage: error.localizedDescription
                    )
                    SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
                    completion(token, error)
                }
            
        }
    }
    
    internal func logout() -> Promise<Void> {
        return Promise<Void> { seal in
            guard let spotKey = SPClientSettings.main.spotKey else {
                let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
                seal.reject(SPNetworkError.custom(message))
                return
            }
            
            let spRequest = SPInternalAuthRequests.logout

            var headers = HTTPHeaders.basic(with: spotKey)
            if let token = SPUserSessionHolder.session.token {
                headers[APIHeadersConstants.authorization] = token
            }

            manager.execute(
                request: spRequest,
                parser: OWEmptyParser(),
                headers: headers
            ) { result, response in
                switch result {
                case .success:
                    SPUserSessionHolder.resetUserSession()
                    seal.fulfill_()
                case .failure(let error):
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: nil,
                        errorData: response.data,
                        errorMessage: error.localizedDescription
                    )
                    SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
                    seal.reject(error)
                }
            }
        }
    }
    
    internal func user() -> Promise<SPUser> {
        return Promise<SPUser> { seal in
            guard let spotKey = SPClientSettings.main.spotKey else {
                let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
                seal.reject(SPNetworkError.custom(message))
                return
            }

            let spRequest = SPInternalAuthRequests.user
            var headers = HTTPHeaders.basic(with: spotKey)
            headers[APIHeadersConstants.authorization] = "dfsdszdsafdsada"

            manager.execute(
                request: spRequest,
                parser: OWDecodableParser<SPUser>(),
                headers: headers
            ) { result, response in
                switch result {
                case .success(let user):
                    SPUserSessionHolder.updateSession(with: response.response)
                    SPUserSessionHolder.updateSessionUser(user: user)
                    seal.fulfill(user)
                case .failure(let error):
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: nil,
                        errorData: response.data,
                        errorMessage: error.localizedDescription
                    )
                    SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
                    seal.reject(error)
                }
            }
        }
    }
}
