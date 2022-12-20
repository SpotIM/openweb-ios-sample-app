//
//  OWCloudinaryEndpoint.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 20/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

enum OWImagesEndpoints: OWEndpoints {
    case fetchImage(url: URL)
    case login(publicId: String, timestamp: String)
    case upload(signature: String, publicId: String, timestamp: String, imageData: String)

    // MARK: - HTTPMethod
    var method: OWNetworkHTTPMethod {
        switch self {
        case .fetchImage:
            return .get
        case .login:
            return .post
        case .upload:
            return .post
        }
    }

    // MARK: - Path
    var path: String {
        switch self {
        case .fetchImage(let url): return url.absoluteString
        case .upload: return ""
        case .login: return "/conversation/sign-upload"
        }
    }

    // MARK: - Parameters
    var parameters: OWNetworkParameters? {
        switch self {
        case .fetchImage:
            return nil
        case .login(let publicId, let timestamp):
            return [
                "query": "public_id=\(publicId)&timestamp=\(timestamp)"
            ]
        case .upload(let signature, let publicId, let timestamp, let imageData):
            return [
                "api_key": SPImageRequestConstants.cloudinaryApiKey,
                "signature": signature,
                "public_id": publicId,
                "timestamp": timestamp,
                "file": SPImageRequestConstants.imageFileJpegBase64Prefix + imageData
            ]
        }
    }
    
    // MARK: - Base URL
    var overrideBaseURL: URL? {
        switch self {
        case .fetchImage: return URL(string: APIConstants.fetchImageBaseURL)
        case .login: return URL(string: APIConstants.baseURLString)
        case .upload: return URL(string: APIConstants.uploadImageBaseURL)
        }
    }
}

protocol OWImagesAPI {
    func fetchImage(url: URL) -> OWNetworkResponse<Data>
    func login(publicId: String, timestamp: String) -> OWNetworkResponse<SPSignResponse>
    func upload(signature: String, publicId: String, timestamp: String, imageData: String) -> OWNetworkResponse<SPComment.Content.Image>
}

extension OWNetworkAPI: OWImagesAPI {
    // Access by .images for readability
    var images: OWImagesAPI { return self }
    
    func fetchImage(url: URL) -> OWNetworkResponse<Data> {
        let endpoint = OWImagesEndpoints.fetchImage(url: url)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
    
    func login(publicId: String, timestamp: String) -> OWNetworkResponse<SPSignResponse> {
        let endpoint = OWImagesEndpoints.login(publicId: publicId, timestamp: timestamp)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
    
    func upload(signature: String, publicId: String, timestamp: String, imageData: String) -> OWNetworkResponse<SPComment.Content.Image> {
        let endpoint = OWImagesEndpoints.upload(signature: signature, publicId: publicId, timestamp: timestamp, imageData: imageData)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}
