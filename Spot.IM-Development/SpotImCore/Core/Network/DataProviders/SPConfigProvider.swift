//
//  SPConfigProvider.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 25/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

internal protocol SPConfigProvider {
    static func getConfigs(completion: @escaping (ConfigsCompletion) -> Void)
}

typealias ConfigsCompletion = (appConfig: SPSpotConfiguration?, adsConfig: SPAdsConfiguration?, error: Error?)

internal final class SPDefaultConfigProvider: SPConfigProvider {
    
    /// app and ads configurations
    static func getConfigs(completion: @escaping (ConfigsCompletion) -> Void) {
        guard let spotKey = SPClientSettings.spotKey else {
            let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
            completion((nil, nil, SPNetworkError.custom(message)))
            return
        }
        let spRequest = SPConfigRequests.config(spotId: spotKey)

        let headers = HTTPHeaders.unauthorized(with: spotKey, postId: "")
        Alamofire.request(spRequest.url,
                          method: spRequest.method,
                          parameters: nil,
                          encoding: APIConstants.encoding,
                          headers: headers)
            .validate()
            .responseData { (response) in
                let result: Result<SPSpotConfiguration> = defaultDecoder.decodeResponse(from: response)
                switch result {
                case .success(let appConfig):
                    if appConfig.initialization?.monetized ?? false {
                        getAdsConfig { (adsConfig, error) in
                            completion((appConfig, adsConfig, nil))
                        }
                    } else {
                        completion((appConfig, nil, nil))
                    }
                case .failure(let error):
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: nil,
                        errorData: response.data,
                        errorMessage: error.localizedDescription
                    )
                    SPDefaultFailureReporter().sendFailureReport(rawReport)
                    completion((nil, nil, SPNetworkError.default))
                }
            }
    }
    
    static func getAdsConfig(completion: @escaping (SPAdsConfiguration?, Error?) -> Void) {
        guard let spotKey = SPClientSettings.spotKey else {
            let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
            completion(nil, SPNetworkError.custom(message))
            return
        }
        let spRequest = SPAdsConfigRequest.adsConfig
        let dayName = Date.dayNameFormatter.string(from: Date()).lowercased()
        let hour = Int(Date.hourFormatter.string(from: Date()))!
        let params: [String: Any] = ["day": dayName, "hour": hour]
        let headers = HTTPHeaders.unauthorized(with: spotKey, postId: "")
        Alamofire.request(spRequest.url,
                          method: spRequest.method,
                          parameters: params,
                          encoding: APIConstants.encoding,
                          headers: headers)
            .validate()
            .responseData { (response) in
                
                let result: Result<SPAdsConfiguration> = defaultDecoder.decodeResponse(from: response)
                switch result {
                case .success(let configuration):
                    completion(configuration, nil)
                    
                case .failure(let error):
                    Logger.error(error)
                    completion(nil, SPNetworkError.default)
                }
            }
    }

}
