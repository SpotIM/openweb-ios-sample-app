//
//  ImageCache.swift
//  Spot.IM-Core
//
//  Created by Eugene on 9/5/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

final class OWImageCache: OWCacheService<String, UIImage> {
    
    static let sdkCache = OWImageCache()
    
    /// Nil will remove image from cache
    func setImage(image: UIImage?, for key: String) {
        self[key] = image
    }
    
    func image(for key: String) -> UIImage? {
        return self[key]
    }
}
