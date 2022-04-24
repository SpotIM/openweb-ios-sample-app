//
//  OWSharedServicesProvider.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

protocol OWSharedServicesProviding {
    func themeStyleService() -> OWThemeStyleServicing
    func imageCacheService() -> OWCacheService<String, UIImage>
    func commentsInMemoryCacheService() -> OWCacheService<String, String>
    func netwokAPI() -> OWNetworkAPI
}

class OWSharedServicesProvider: OWSharedServicesProviding {
    
    // Singleton
    static let shared: OWSharedServicesProviding = OWSharedServicesProvider()

    private init() {

    }

    fileprivate lazy var _themeStyleService: OWThemeStyleServicing = {
        return OWThemeStyleService()
    }()
    
    fileprivate lazy var _imageCacheService: OWCacheService<String, UIImage> = {
        return OWCacheService<String, UIImage>()
    }()
    
    fileprivate lazy var _commentsInMemoryCacheService: OWCacheService<String, String> = {
        return OWCacheService<String, String>()
    }()
    
    fileprivate lazy var _networkAPI: OWNetworkAPI = {
        /*
         By default we create the network once.
         If we will want to "reset" everything when a new spotIfy provided, we can re-create the network entirely.
         Note that the environment is being set in the `OWEnvironment` class which we can set in an earlier step by some
         environment variable / flag in Xcode scheme configuration.
        */
        return OWNetworkAPI(environment: OWEnvironment.currentEnvironment)
    }()
    
    func themeStyleService() -> OWThemeStyleServicing {
        return _themeStyleService
    }
    
    func imageCacheService() -> OWCacheService<String, UIImage> {
        return _imageCacheService
    }
    
    func commentsInMemoryCacheService() -> OWCacheService<String, String> {
        return _commentsInMemoryCacheService
    }
    
    func netwokAPI() -> OWNetworkAPI {
        return _networkAPI
    }
}
