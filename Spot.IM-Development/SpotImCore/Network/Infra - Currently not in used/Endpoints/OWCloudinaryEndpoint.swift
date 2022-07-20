//
//  OWCloudinaryEndpoint.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 20/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

enum OWCloudinaryEndpoint: OWEndpoint {
    case fetchImage(url: URL)
    case login(publicId: String, timestamp: String)
case upload(signature: String, publicId: String, timestamp: String, imageData: String)

    // MARK: - HTTPMethod
    var method: HTTPMethod {
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
        // MARK: TODO - these EP are not to our mobileGW, we should find a way to map it properly
        // MARK: TODO - check why there is no use in url given to fetchImage and how is it working today !?
        case .fetchImage, .upload: return ""
        case .login: return "/conversation/sign-upload"
        }
    }

    // MARK: - Parameters
    var parameters: Parameters? {
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
}

protocol OWCloudinaryAPI {
    func fetchImage(url: URL) -> OWNetworkResponse<Data>
    func login() -> OWNetworkResponse<SPSignResponse>
//    func upload() -> ??
}
