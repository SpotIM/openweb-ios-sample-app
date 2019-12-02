//
//  SPImagesFacade.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 06/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

internal protocol SPImageURLProvider {
    
    var avatarSize: CGSize? { get set }
    func imageURL(with id: String?, size: CGSize?) -> URL?
    
    @discardableResult
    func image(with url: URL?, size: CGSize?, completion: @escaping ImageLoadingCompletion) -> DataRequest?
}

internal final class SPCloudinaryImageProvider: NetworkDataProvider, SPImageURLProvider {
    internal var avatarSize: CGSize?
    
    /// Use prepared url with size here, please
    @discardableResult
    func image(with url: URL?, size: CGSize? = nil,
               completion: @escaping ImageLoadingCompletion) -> DataRequest? {
        guard let url = url else { return nil }
        
        if let image = ImageCache.sdkCache.image(for: url.absoluteString) {
            completion(image, nil)
            
            return nil
        } else {
            let request = SPImageFetchRequest.image(url: url)
            
            return manager.execute(
                request: request,
                encoding: URLEncoding.default,
                parser: DecodableParser<Data>()) { (result, _) in
                    switch result {
                    case .success(let data):
                        let image = UIImage(data: data)
                        if let size = size, let image = image {
                            let scale = UIScreen.main.scale
                            UIGraphicsBeginImageContextWithOptions(size, false, scale)
                            image.draw(in: CGRect(origin: .zero, size: size))
                            let newIM = UIGraphicsGetImageFromCurrentImageContext()
                            UIGraphicsEndImageContext()
                            ImageCache.sdkCache.setImage(image: newIM, for: url.absoluteString)
                            completion(newIM, nil)
                        } else {
                            ImageCache.sdkCache.setImage(image: image, for: url.absoluteString)
                            completion(image, nil)
                        }
                    case .failure(let error):
                        completion(nil, error)
                    }
            }
        }
    }
    
    func imageURL(with id: String?, size: CGSize? = nil) -> URL? {
        guard var id = id else { return nil }
        
        if id.hasPrefix(Constants.placeholderImagePrefix) {
            id.removeFirst(Constants.placeholderImagePrefix.count)
            id = Constants.avatarPathComponent.appending(id)
        }
        return URL(string: cloudinaryURLString(size).appending(id))
    }

    private func cloudinaryURLString(_ imageSize: CGSize? = nil) -> String {
        var result = Constants.cloudinaryBaseURL.appending(Constants.cloudinaryParamString)
        
        if let imageSize = imageSize {
            result.append("\(Constants.cloudinaryWidthPrefix)" +
                "\(Int(imageSize.width))" +
                "\(Constants.cloudinaryHeightPrefix)" +
                "\(Int(imageSize.height))"
            )
        } else if let avatarSize = avatarSize {
            result.append("\(Constants.cloudinaryWidthPrefix)" +
                "\(Int(avatarSize.width))" +
                "\(Constants.cloudinaryHeightPrefix)" +
                "\(Int(avatarSize.height))"
            )
        }
        
        return result.appending("/")
    }
}

private enum Constants {
    static let cloudinaryBaseURL = "https://images.spot.im/image/upload/"
    static let cloudinaryParamString = "dpr_3,c_thumb,g_face"
    static let cloudinaryWidthPrefix = ",w_"
    static let cloudinaryHeightPrefix = ",h_"
    static let placeholderImagePrefix = "#"
    static let avatarPathComponent = "avatars/"
}
