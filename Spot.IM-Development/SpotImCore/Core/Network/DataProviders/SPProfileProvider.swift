//
//  SPProfileProvider.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 09/06/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

internal final class SPProfileProvider: NetworkDataProvider {
    
    func getSingleUseToken() -> Promise<String?> {
        return Promise<String?> { seal in
            guard let spotKey = SPClientSettings.main.spotKey else {
                let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
                return seal.reject(SPNetworkError.custom(message))
            }
            
            let spRequest = SPProfileRequest.createSingleUseToken
            let headers = HTTPHeaders.basic(with: spotKey)
            var requestParams: [String: Any] = ["access_token": SPUserSessionHolder.session.token?.replacingOccurrences(of: "Bearer ", with: "")]
            if let openwebToken = SPUserSessionHolder.session.openwebToken {
                requestParams["open_web_token"] = openwebToken
            }

            manager.execute(
                request: spRequest,
                parameters: requestParams,
                parser: DecodableParser<[String: String]>(),
                headers: headers
            ) { result, response in
                switch result {
                case .success(let dictionary):
                    seal.fulfill(dictionary["single_use_token"])
                case .failure(let error):
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: requestParams,
                        errorData: response.data,
                        errorMessage: error.localizedDescription
                    )
                    SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
                    seal.reject(SpotImError.internalError(error.localizedDescription))
                }
            }
        }
    }
}
