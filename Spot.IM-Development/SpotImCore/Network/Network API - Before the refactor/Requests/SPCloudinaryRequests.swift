//
//  SPImageFetchRequest.swift
//  SpotImCore
//
//  Created by Eugene on 11.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal enum SPCloudinaryRequests: SPRequest {
    case fetchImage(url: URL)
    case login
    case upload

    internal var method: OWNetworkHTTPMethod {
        switch self {
        case .fetchImage: return .get
        case .login: return .post
        case .upload: return .post
        }
    }

    internal var pathString: String {
        switch self {
        case .fetchImage, .upload: return ""
        case .login: return "/conversation/sign-upload"
        }
    }

    internal var url: URL! {
        switch self {
        case .fetchImage: return URL(string: APIConstants.fetchImageBaseURL)
        case .login: return URL(string: APIConstants.baseURLString.appending(pathString))
        case .upload: return URL(string: APIConstants.uploadImageBaseURL)
        }
    }
}
