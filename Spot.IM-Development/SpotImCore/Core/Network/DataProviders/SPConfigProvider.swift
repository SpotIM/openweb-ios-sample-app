//
//  SPConfigProvider.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 25/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

internal protocol SPConfigProvider {
    func fetchConfigs() -> Promise<SpotConfig>
}

internal struct SpotConfig {
    let appConfig: SPSpotConfiguration
    let adsConfig: SPAdsConfiguration?
}
internal final class SPDefaultConfigProvider: NetworkDataProvider, SPConfigProvider {
    
    /// app and ads configurations
    func fetchConfigs() -> Promise<SpotConfig> {
        return Promise<SpotConfig> { seal in
            guard let spotKey = SPClientSettings.main.spotKey else {
                let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
                return seal.reject(SPNetworkError.custom(message))
            }
            let spRequest = SPConfigRequests.config(spotId: spotKey)
            
            let headers = HTTPHeaders.basic(with: spotKey)
            
            manager.execute(
                request: spRequest,
                parser: DecodableParser<SPSpotConfiguration>(),
                headers: headers
            ) { result, response in
                switch result {
                case .success(let appConfig):
                    if appConfig.initialization?.monetized ?? false {
                        self.getAdsConfig { (adsConfig, error) in
                            SPConfigsDataSource.adsConfig = adsConfig
                            SPConfigsDataSource.appConfig = appConfig
                            seal.fulfill(SpotConfig(appConfig: appConfig, adsConfig: adsConfig))
                        }
                    } else {
                        SPConfigsDataSource.appConfig = appConfig
                        seal.fulfill(SpotConfig(appConfig: appConfig, adsConfig: nil))
                    }
                case .failure(let error):
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: nil,
                        errorData: response.data,
                        errorMessage: error.localizedDescription
                    )
                    SPDefaultFailureReporter().sendFailureReport(rawReport)
                    seal.reject(SpotImError.internalError(error.localizedDescription))
                }
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
        let headers = HTTPHeaders.basic(with: spotKey)
        
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
