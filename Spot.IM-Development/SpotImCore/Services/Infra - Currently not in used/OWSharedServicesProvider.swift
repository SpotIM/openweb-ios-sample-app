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
    
    func themeStyleService() -> OWThemeStyleServicing {
        return _themeStyleService
    }
    
    func imageCacheService() -> OWCacheService<String, UIImage> {
        return _imageCacheService
    }
    
    func commentsInMemoryCacheService() -> OWCacheService<String, String> {
        return _commentsInMemoryCacheService
    }
}
