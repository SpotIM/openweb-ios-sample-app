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
    let abConfig: OWAbTests
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
            
            getConfig(spotId: spotKey).then { config -> Promise<(SPSpotConfiguration, OWAbTests)> in
                if config.mobileSdk.enabled ?? false {
                    return self.getAbTests(spotId: spotKey, config: config).map { (config, $0) }
                } else {
                    return Promise.value((config, OWAbTests(tests: [])))
                }
            }.then { configAndAbTest -> Promise<SpotConfig> in
                if configAndAbTest.0.mobileSdk.enabled ?? false && configAndAbTest.0.initialization?.monetized ?? false {
                    return self.getAdsConfig(spotId: spotKey).map { return SpotConfig(appConfig: configAndAbTest.0, abConfig: configAndAbTest.1, adsConfig: $0) }
                } else {
                    return Promise.value(SpotConfig(appConfig: configAndAbTest.0, abConfig: configAndAbTest.1, adsConfig: nil))
                }
            }.done { spotConfig in
                seal.fulfill(spotConfig)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    private func getConfig(spotId: String) -> Promise<SPSpotConfiguration> {
        return Promise<SPSpotConfiguration> { seal in
            let spRequest = SPConfigRequests.config(spotId: spotId)
            
            let headers = HTTPHeaders.basic(with: spotId)
            
            manager.execute(
                request: spRequest,
                parser: OWDecodableParser<SPSpotConfiguration>(),
                headers: headers
            ) { result, response in
                switch result {
                case .success(let appConfig):
                    SPConfigsDataSource.appConfig = appConfig
                    seal.fulfill(appConfig)
                case .failure(let error):
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: nil,
                        errorData: response.data,
                        errorMessage: error.localizedDescription
                    )
                    SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
                    seal.reject(SpotImError.internalError(error.localizedDescription))
                }
            }

        }
    }
    private func getAdsConfig(spotId: String) -> Promise<SPAdsConfiguration> {
        return Promise<SPAdsConfiguration> { seal in
            let spRequest = SPAdsConfigRequest.adsConfig
            let dayName = Date.dayNameFormatter.string(from: Date()).lowercased()
            let hour = Int(Date.hourFormatter.string(from: Date()))!
            let params: [String: Any] = ["day": dayName, "hour": hour]
            let headers = HTTPHeaders.basic(with: spotId)
            
            manager.execute(
                request: spRequest,
                parameters: params,
                parser: OWDecodableParser<SPAdsConfiguration>(),
                headers: headers
            ) { result, response in
                switch result {
                case .success(let configuration):
                    SPConfigsDataSource.adsConfig = configuration
                    seal.fulfill(configuration)
                case .failure(let error):
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: nil,
                        errorData: response.data,
                        errorMessage: error.localizedDescription
                    )
                    SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
                    seal.reject(SpotImError.internalError(error.localizedDescription))
                }
            }
        }
    }
    
    private func getAbTests(spotId: String, config: SPSpotConfiguration) -> Promise<OWAbTests> {
        return Promise<OWAbTests> { seal in
            // THIS IS THE FINAL RESULT OF THE ONLY TEST WE HAD ON IOS
            var tests = [SPABData(testName: "33", group: "D")]
            if let monetized = config.initialization?.monetized, monetized {
                tests = [SPABData(testName: "33", group: "B")]
            }
            seal.fulfill(OWAbTests(tests: tests))
            
            // REMOVING THIS CALL UNTIL WE WILL HAVE ACTIVE TESTS BACK ON IOS TO REDUCE STRESS FROM BE
//            let spRequest = SPConfigRequests.abTestData
//
//            let headers = HTTPHeaders.basic(with: spotId)
            
//            manager.execute(
//                request: spRequest,
//                parser: DecodableParser<AbTests>(),
//                headers: headers
//            ) { result, response in
//                switch result {
//                case .success(let abTestData):
//                    SPAnalyticsHolder.abActiveTests = abTestData.getActiveTests()
//                    seal.fulfill(abTestData)
//                case .failure(let error):
//                    let rawReport = RawReportModel(
//                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
//                        parameters: nil,
//                        errorData: response.data,
//                        errorMessage: error.localizedDescription
//                    )
//                    SPDefaultFailureReporter.shared.sendFailureReport(rawReport)
//                    seal.reject(SpotImError.internalError(error.localizedDescription))
//                }
//            }
        }
    }

}
