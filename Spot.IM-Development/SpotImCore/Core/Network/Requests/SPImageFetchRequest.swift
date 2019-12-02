//
//  SPImageFetchRequest.swift
//  SpotImCore
//
//  Created by Eugene on 11.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

internal enum SPImageFetchRequest: SPRequest {
    case image(url: URL)

    internal var method: HTTPMethod {
        switch self {
        case .image: return .get
        }
    }

    internal var pathString: String {
        switch self {
        case .image: return ""
        }
    }

    internal var url: URL! {
        switch self {
        case .image(let url): return url
        }
    }
}
