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

    internal var method: HTTPMethod {
        switch self {
        case .fetchImage: return .get
        }
    }

    internal var pathString: String {
        switch self {
        case .fetchImage: return ""
        }
    }

    internal var url: URL! {
        switch self {
        case .fetchImage(let url): return url
        }
    }
}
