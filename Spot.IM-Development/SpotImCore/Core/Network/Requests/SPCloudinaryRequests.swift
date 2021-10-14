//
//  SPImageFetchRequest.swift
//  SpotImCore
//
//  Created by Eugene on 11.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

internal enum SPCloudinaryRequests: SPRequest {
    case fetchImage(url: URL)
    case login
    case upload

    internal var method: HTTPMethod {
        switch self {
        case .fetchImage: return .get
        case .login: return .post
        case .upload: return .post
        }
    }

    internal var pathString: String {
        switch self {
        case .fetchImage: return ""
        case .login: return "/extract/cloudinary/sign"
        case .upload: return "/image/upload"
        }
    }

    internal var url: URL! {
        switch self {
        case .fetchImage(let url): return url
        case .login: return URL(string: APIConstants.spotimGatewayApiUrlString.appending(pathString))
        case .upload: return URL(string: APIConstants.cloudinaryUploadBaseURL.appending(pathString))
        }
    }
}
