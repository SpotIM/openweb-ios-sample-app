//
//  UIImageView+SPExtensions.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 24/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import Alamofire

typealias ImageLoadingCompletion = (_ image: UIImage?, _ error: Error?) -> Void

internal extension UIImageView {
    @discardableResult
    func setImage(with url: URL?, completion: ImageLoadingCompletion? = nil) -> DataRequest? {
        return UIImage.load(with: url) { image, error in
            if let completion = completion {
                completion(image, error)
            } else if (error != nil) {
                self.image = nil
            } else {
                self.image = image
            }
        }
    }
}

internal extension UIImage {
    @discardableResult
    static func load(with url: URL?, completion: ImageLoadingCompletion? = nil) -> DataRequest? {
        guard let url = url else {
            completion?(nil, SPNetworkError.custom("No image URL"))
            return nil
        }
        if let image = ImageCache.sdkCache.image(for: url.absoluteString) {
            completion?(image, nil)
            
            return nil
        } else {
            return AF.request(url)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        let image = UIImage(data: data)
                        
                        ImageCache.sdkCache.setImage(image: image, for: url.absoluteString)
                        if let completion = completion {
                            completion(image, nil)
                        }
                    case .failure(let error):
                        completion?(nil, error)
                    }
                }
        }
    }
}
