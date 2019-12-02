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
    func getConfigs(completion: @escaping (ConfigsCompletion) -> Void)
}

typealias ConfigsCompletion = (appConfig: SPSpotConfiguration?, adsConfig: SPAdsConfiguration?, error: Error?)

internal final class SPDefaultConfigProvider: NetworkDataProvider, SPConfigProvider {
    
    /// app and ads configurations
    func getConfigs(completion: @escaping (ConfigsCompletion) -> Void) {
        guard let spotKey = SPClientSettings.main.spotKey else {
            let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
            completion((nil, nil, SPNetworkError.custom(message)))
            return
        }
        let spRequest = SPConfigRequests.config(spotId: spotKey)

        let headers = HTTPHeaders.unauthorized(with: spotKey, postId: "")
        
        manager.execute(
            request: spRequest,
            parser: DecodableParser<SPSpotConfiguration>(),
            headers: headers
        ) { [weak self] result, response in
            guard let self = self else { return }
            
            switch result {
            case .success(let appConfig):
                if appConfig.initialization?.monetized ?? false {
                    self.getAdsConfig { (adsConfig, error) in
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
    
    func getAdsConfig(completion: @escaping (SPAdsConfiguration?, Error?) -> Void) {
        guard let spotKey = SPClientSettings.main.spotKey else {
            let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
            completion(nil, SPNetworkError.custom(message))
            return
        }
        let spRequest = SPAdsConfigRequest.adsConfig
        let dayName = Date.dayNameFormatter.string(from: Date()).lowercased()
        let hour = Int(Date.hourFormatter.string(from: Date()))!
        let params: [String: Any] = ["day": dayName, "hour": hour]
        let headers = HTTPHeaders.unauthorized(with: spotKey, postId: "")
        
        manager.execute(
            request: spRequest,
            parameters: params,
            parser: DecodableParser<SPAdsConfiguration>(),
            headers: headers
        ) { result, response in
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
