//
//  SPConfigProvider.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 25/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

internal protocol SPConfigProvider {
    func fetchConfigs() -> Observable<SpotConfig>
}

internal struct SpotConfig {
    let appConfig: SPSpotConfiguration
    let abConfig: OWAbTests
    let adsConfig: SPAdsConfiguration?
}

internal final class SPDefaultConfigProvider: NetworkDataProvider, SPConfigProvider {
    
    /// app and ads configurations
    func fetchConfigs() -> Observable<SpotConfig> {
        guard let spotKey = SPClientSettings.main.spotKey else {
            let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
            return Observable.error(SPNetworkError.custom(message))
        }
        
        return self.getConfig(spotId: spotKey)
            .flatMap { [weak self] config -> Observable<(SPSpotConfiguration, OWAbTests)> in
                guard let self = self else { return .empty() }
                if config.mobileSdk.enabled ?? false {
                    return self.getAbTests(spotId: spotKey, config: config).map { (config, $0) }
                } else {
                    return Observable.just((config, OWAbTests(tests: [])))
                }
            }
            .flatMap { [weak self] configAndAbTest -> Observable<SpotConfig> in
                guard let self = self else { return .empty() }
                
                if configAndAbTest.0.mobileSdk.enabled ?? false && configAndAbTest.0.initialization?.monetized ?? false {
                    return self.getAdsConfig(spotId: spotKey)
                        .map { SpotConfig(appConfig: configAndAbTest.0, abConfig: configAndAbTest.1, adsConfig: $0) }
                } else {
                    return Observable.just(SpotConfig(appConfig: configAndAbTest.0, abConfig: configAndAbTest.1, adsConfig: nil))
                }
            }
    }
    
    private func getConfig(spotId: String) -> Observable<SPSpotConfiguration> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                return Disposables.create()
            }
            
            let spRequest = SPConfigRequests.config(spotId: spotId)
            let headers = HTTPHeaders.basic(with: spotId)
            
            let task = self.manager.execute(
                request: spRequest,
                parser: OWDecodableParser<SPSpotConfiguration>(),
                headers: headers
            ) { result, response in
                switch result {
                case .success(let appConfig):
                    SPConfigsDataSource.appConfig = appConfig
                    observer.onNext(appConfig)
                    observer.onCompleted()
                case .failure(let error):
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: nil,
                        errorData: response.data,
                        errorMessage: error.localizedDescription
                    )
                    SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
                    observer.onError(SpotImError.internalError(error.localizedDescription))
                }
            }
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    private func getAdsConfig(spotId: String) -> Observable<SPAdsConfiguration> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                return Disposables.create()
            }
            
            let spRequest = SPAdsConfigRequest.adsConfig
            let dayName = Date.dayNameFormatter.string(from: Date()).lowercased()
            let hour = Int(Date.hourFormatter.string(from: Date()))!
            let params: [String: Any] = ["day": dayName, "hour": hour]
            let headers = HTTPHeaders.basic(with: spotId)
            
            let task = self.manager.execute(
                request: spRequest,
                parameters: params,
                parser: OWDecodableParser<SPAdsConfiguration>(),
                headers: headers
            ) { result, response in
                switch result {
                case .success(let configuration):
                    SPConfigsDataSource.adsConfig = configuration
                    observer.onNext(configuration)
                    observer.onCompleted()
                case .failure(let error):
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: nil,
                        errorData: response.data,
                        errorMessage: error.localizedDescription
                    )
                    SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
                    observer.onError(SpotImError.internalError(error.localizedDescription))
                }
            }
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    private func getAbTests(spotId: String, config: SPSpotConfiguration) -> Observable<OWAbTests> {
        return Observable.create { observer in
            var tests = [SPABData(testName: "33", group: "D")]
            if let monetized = config.initialization?.monetized, monetized {
                tests = [SPABData(testName: "33", group: "B")]
            }
            
            observer.onNext(OWAbTests(tests: tests))
            observer.onCompleted()
            
            return Disposables.create()
        }
        
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
