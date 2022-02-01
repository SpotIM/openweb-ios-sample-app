//
//  ImageCache.swift
//  Spot.IM-Core
//
//  Created by Eugene on 9/5/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

private let defaultCountLimit: Int = 50

final class ImageCache {
    
    static let sdkCache = ImageCache()
    
    private let cacheInstance: NSCache<NSString, UIImage>
    
    private init() {
        cacheInstance = NSCache<NSString, UIImage>()
        cacheInstance.countLimit = defaultCountLimit
    }
    
    /// Nil will remove image from cache
    func setImage(image: UIImage?, for key: String) {
        if let image = image {
            cacheInstance.setObject(image, forKey: NSString(string: key))
        } else {
            cacheInstance.removeObject(forKey: NSString(string: key))
        }
    }
    
    func image(for key: String) -> UIImage? {
        guard
            let cachedData = cacheInstance.object(forKey: NSString(string: key))
            else { return nil }
        
        return cachedData
    }
}
