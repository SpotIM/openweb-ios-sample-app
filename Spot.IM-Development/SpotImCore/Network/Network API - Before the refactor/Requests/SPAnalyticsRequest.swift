//
//  SPAnalyticsRequest.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 02/09/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal enum SPAnalyticsRequest: SPRequest {
    case analytics

    internal var method: HTTPMethod {
        switch self {
        case .analytics: return .post
        }
    }

    internal var pathString: String {
        switch self {
        case .analytics: return "/event"
        }
    }

    internal var url: URL! {
        return URL(string: APIConstants.baseURLString.appending(pathString))
    }
}
