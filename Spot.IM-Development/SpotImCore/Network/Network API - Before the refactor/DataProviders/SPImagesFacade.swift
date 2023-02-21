//
//  SPImagesFacade.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 06/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

internal protocol SPImageProvider {

    var avatarSize: CGSize? { get set }
    func imageURL(with id: String?, size: CGSize?) -> URL?

    @discardableResult
    func image(from url: URL?, size: CGSize?, completion: @escaping ImageLoadingCompletion) -> OWNetworkDataRequest?

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
               completion: @escaping ImageLoadingCompletion) -> OWNetworkDataRequest? {
        guard let url = url else { return nil }

        let imageCacheService = OWSharedServicesProvider.shared.imageCacheService()
        if let image = imageCacheService[url.absoluteString] {
            completion(image, nil)

            return nil
        } else {
            let request = SPCloudinaryRequests.fetchImage(url: url)

            return manager.execute(
                request: request,
                encoding: OWNetworkURLEncoding.default,
                parser: OWDecodableParser<Data>()) { (result, _) in
                    switch result {
                    case .success(let data):
                        let image = UIImage(data: data)
                        if let size = size, let image = image {
                            let scale = UIScreen.main.scale
                            UIGraphicsBeginImageContextWithOptions(size, false, scale)
                            image.draw(in: CGRect(origin: .zero, size: size))
                            let newIM = UIGraphicsGetImageFromCurrentImageContext()
                            UIGraphicsEndImageContext()
                            imageCacheService[url.absoluteString] = newIM
                            completion(newIM, nil)
                        } else {
                            imageCacheService[url.absoluteString] = image
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
            "api_key": SPImageRequestConstants.cloudinaryApiKey,
            "signature": signature,
            "public_id": publicId,
            "timestamp": timestamp,
            "file": SPImageRequestConstants.imageFileJpegBase64Prefix + imageData
        ]

        manager.execute(
            request: SPCloudinaryRequests.upload,
            parameters: parameters,
            parser: OWDecodableParser<CloudinaryUploadResponse>()) { (result, _) in
            switch result {
            case .success(let response):
                let image = SPComment.Content.Image(
                    originalWidth: response.width,
                    originalHeight: response.height,
                    imageId: publicId
                )
                completion(image, nil)

            case .failure(let err):
                completion(nil, err)

            }
        }
    }

    private func signToCloudinary(publicId: String, timestamp: String, completion: @escaping (String?, Error?) -> Void) {
        guard let spotKey = SPClientSettings.main.spotKey else {
            servicesProvider.logger().log(level: .error, "No spot key for signing")
            return
        }
        let headers = OWNetworkHTTPHeaders.basic(with: spotKey)
        let parameters: [String: Any] = [
            "query": "public_id=\(publicId)&timestamp=\(timestamp)"
        ]

        manager.execute(
            request: SPCloudinaryRequests.login,
            parameters: parameters,
            parser: OWDecodableParser<SPSignResponse>(),
            headers: headers) { (result, _) in
            switch result {
            case .success(let response):
                completion(response.signature, nil)

            case .failure(let err):
                completion(nil, err)

            }
        }
    }

    func imageURL(with id: String?, size: CGSize? = nil) -> URL? {
        guard var id = id else { return nil }

        if id.hasPrefix(SPImageRequestConstants.placeholderImagePrefix) {
            id.removeFirst(SPImageRequestConstants.placeholderImagePrefix.count)
            id = SPImageRequestConstants.avatarPathComponent.appending(id)
        }
        return URL(string: cloudinaryURLString(size).appending(id))
    }

    private func cloudinaryURLString(_ imageSize: CGSize? = nil) -> String {
        var result = APIConstants.fetchImageBaseURL.appending(SPImageRequestConstants.cloudinaryImageParamString)

        if let imageSize = imageSize {
            result.append("\(SPImageRequestConstants.cloudinaryWidthPrefix)" +
                "\(Int(imageSize.width))" +
                "\(SPImageRequestConstants.cloudinaryHeightPrefix)" +
                "\(Int(imageSize.height))"
            )
        } else if let avatarSize = avatarSize {
            result.append("\(SPImageRequestConstants.cloudinaryWidthPrefix)" +
                "\(Int(avatarSize.width))" +
                "\(SPImageRequestConstants.cloudinaryHeightPrefix)" +
                "\(Int(avatarSize.height))"
            )
        }

        return result.appending("/")
    }
}

internal enum SPImageRequestConstants {
    static let cloudinaryApiKey = "281466446316913"
    static let cloudinaryImageParamString = "dpr_3,c_thumb,g_face"
    static let cloudinaryWidthPrefix = ",w_"
    static let cloudinaryHeightPrefix = ",h_"
    static let placeholderImagePrefix = "#"
    static let avatarPathComponent = "avatars/"
    static let imageFileJpegBase64Prefix = "data:image/jpeg;base64,"
    static let cloudinaryIconParamString = "f_png/"
    static let fontAwesomePathComponent = "font-awesome/"
    static let fontAwesomeVersionPathComponent = "v5.15.2/"
    static let iconsPathComponent = "icons/"
    static let customPathComponent = "custom/"
}
