//
//  OWMuteRequest.swift
//  SpotImCore
//
//  Created by Revital Pisman on 30/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

internal enum OWMuteRequest: SPRequest {
    
    case mute
    
    internal var method: OWNetworkHTTPMethod {
        switch self {
            case .mute: return .post
        }
    }
    
    internal var pathString: String {
        switch self {
            case .mute: return "/user/mute-user"
        }
    }
    
    internal var url: URL! {
        switch self {
            case .mute: return URL(string: APIConstants.baseURLString + pathString)
        }
    }
}
