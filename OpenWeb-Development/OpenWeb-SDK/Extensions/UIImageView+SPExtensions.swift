//
//  UIImageView+SPExtensions.swift
//  OpenWebSDK
//
//  Created by Andriy Fedin on 24/06/19.
//  Copyright © 2019 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift

typealias ImageLoadingCompletion = (_ image: UIImage?, _ error: Error?) -> Void

extension UIImageView {
    @discardableResult
    func setImage(with url: URL?, completion: ImageLoadingCompletion? = nil) -> OWNetworkDataRequest? {
        return UIImage.load(with: url) { image, error in
            if let completion {
                completion(image, error)
            } else if error != nil {
                self.image = nil
            } else {
                self.image = image
            }
        }
    }
}

extension UIImage {
    @discardableResult
    static func load(with url: URL?, completion: ImageLoadingCompletion? = nil) -> OWNetworkDataRequest? {
        guard let url else {
            completion?(nil, OWError.custom(description: "No image URL"))
            return nil
        }

        let imageCacheService = OWSharedServicesProvider.shared.imageCacheService()
        if let image = imageCacheService[url.absoluteString] {
            completion?(image, nil)

            return nil
        } else {
            return OWNetworkSession.default.request(url)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        let image = UIImage(data: data)

                        imageCacheService[url.absoluteString] = image
                        if let completion {
                            completion(image, nil)
                        }
                    case .failure(let error):
                        completion?(nil, error)
                    }
                }
        }
    }

    static func load(with url: URL) -> Observable<UIImage> {
        return Observable.create { observer in
            let dataRequest = UIImage.load(with: url, completion: { image, error in
                if let error {
                    observer.onError(error)
                } else if let image {
                    observer.onNext(image)
                    observer.onCompleted()
                }
            })

            return Disposables.create {
                dataRequest?.cancel()
            }
        }
    }
}
