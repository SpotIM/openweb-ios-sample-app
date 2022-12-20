//
//  SPProfileRequest.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 09/06/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation

internal enum SPProfileRequest: SPRequest {
    case createSingleUseToken

    internal var method: HTTPMethod {
        switch self {
        case .createSingleUseToken: return .post
        }
    }

    internal var pathString: String {
        switch self {
        case .createSingleUseToken: return "/profile/create-single-use-token"
        }
    }

    internal var url: URL! {
        return URL(string: APIConstants.baseURLString.appending(pathString))
    }
}
