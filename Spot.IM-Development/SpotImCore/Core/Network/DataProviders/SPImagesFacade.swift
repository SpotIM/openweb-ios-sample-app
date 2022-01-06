//
//  SPImagesFacade.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 06/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

internal protocol SPImageProvider {
    
    var avatarSize: CGSize? { get set }
    func imageURL(with id: String?, size: CGSize?) -> URL?
    
    @discardableResult
    func image(from url: URL?, size: CGSize?, completion: @escaping ImageLoadingCompletion) -> DataRequest?
    
    func uploadImage(imageData: String, imageId: String, completion: @escaping ImageUploadCompletionHandler)
}

internal class SPSignResponse: Decodable {
    let signature: String
}

internal class CloudinaryUploadResponse: Decodable {
    let assetId: String
    let width: Int
    let height: Int
}

typealias ImageUploadCompletionHandler = (SPComment.Content.Image?, Error?) -> Void

internal final class SPCloudinaryImageProvider: NetworkDataProvider, SPImageProvider {
    internal var avatarSize: CGSize?
    
    /// Use prepared url with size here, please
    @discardableResult
    func image(from url: URL?, size: CGSize? = nil,
               completion: @escaping ImageLoadingCompletion) -> DataRequest? {
        guard let url = url else { return nil }
        
        if let image = ImageCache.sdkCache.image(for: url.absoluteString) {
            completion(image, nil)
            
            return nil
        } else {
            let request = SPCloudinaryRequests.fetchImage(url: url)
            
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
    
    func uploadImage(imageData: String, imageId: String, completion: @escaping ImageUploadCompletionHandler) {
        let timestamp = String(format: "%.3f", NSDate().timeIntervalSince1970)
        
        signToCloudinary(publicId: imageId, timestamp: timestamp) { signature, err in
            guard let signature = signature else {
                completion(nil, err)
                return
            }
            
            self.uploadImageToCloudinary(imageData: imageData, publicId: imageId, timestamp: timestamp, signature: signature) { imageData, err in
                completion(imageData, err)
            }
        }
    }
    
    private func uploadImageToCloudinary(imageData: String, publicId: String, timestamp: String, signature: String, completion: @escaping ImageUploadCompletionHandler) {
        
        let parameters: [String: Any] = [
            "api_key": Constants.cloudinaryApiKey,
            "signature": signature,
            "public_id": publicId,
            "timestamp": timestamp,
            "file": Constants.imageFileJpegBase64Prefix + imageData
        ]
        
        manager.execute(
            request: SPCloudinaryRequests.upload,
            parameters: parameters,
            parser: DecodableParser<CloudinaryUploadResponse>()) { (result, _) in
            switch result {
            case .success(let response):
                let image = SPComment.Content.Image(
                    originalWidth: response.width,
                    originalHeight: response.height,
                    imageId: publicId
                )
                completion(image, nil)
                break
            case .failure(let err):
                completion(nil, err)
                break
            }
        }
    }
    
    private func signToCloudinary(publicId: String, timestamp: String, completion: @escaping (String?, Error?) -> Void) {
        guard let spotKey = SPClientSettings.main.spotKey else {
            Logger.error("[ERROR]: No spot key for signing")
            return
        }
        let headers = HTTPHeaders.basic(with: spotKey)
        let parameters: [String: Any] = [
            "query": "public_id=\(publicId)&timestamp=\(timestamp)"
        ]
        
        manager.execute(
            request: SPCloudinaryRequests.login,
            parameters: parameters,
            parser: DecodableParser<SPSignResponse>(),
            headers: headers) { (result, _) in
            switch result {
            case .success(let response):
                completion(response.signature, nil)
                break
            case .failure(let err):
                completion(nil, err)
                break
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
    static let cloudinaryApiKey = "281466446316913"
    static let cloudinaryBaseURL = "https://images.spot.im/image/upload/"
    static let cloudinaryParamString = "dpr_3,c_thumb,g_face"
    static let cloudinaryWidthPrefix = ",w_"
    static let cloudinaryHeightPrefix = ",h_"
    static let placeholderImagePrefix = "#"
    static let avatarPathComponent = "avatars/"
    static let imageFileJpegBase64Prefix = "data:image/jpeg;base64,"
}
