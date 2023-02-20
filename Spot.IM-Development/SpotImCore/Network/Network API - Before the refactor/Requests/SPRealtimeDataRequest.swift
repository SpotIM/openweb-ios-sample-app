//
//  SPRealtimeDataRequest.swift
//  SpotImCore
//
//  Created by Eugene on 12.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal enum SPRealtimeDataRequest: SPRequest {

    case read

    internal var method: OWNetworkHTTPMethod {
        switch self {
        case .read: return .post
        }
    }

    internal var pathString: String {
        switch self {
        case .read: return "/conversation/realtime/read"
        }
    }

    internal var url: URL! {
        switch self {
        case .read: return URL(string: APIConstants.baseURLString.appending(pathString))
        }
    }
}
