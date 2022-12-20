//
//  SPFailureReportRequest.swift
//  Spot.IM-Core
//
//  Created by Eugene on 10/4/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal enum SPFailureReportRequest: SPRequest {
    case error

    internal var method: HTTPMethod {
        switch self {
        case .error: return .post
        }
    }

    internal var pathString: String {
        switch self {
        case .error: return "/error"
        }
    }

    internal var url: URL! {
        return URL(string: APIConstants.baseURLString.appending(pathString))
    }
}
