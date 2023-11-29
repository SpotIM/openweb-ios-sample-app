//
//  OWSSOProvider.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

public enum OWSSOProvider {
    case janrain
    case gigya
    case piano
    case auth0
    case foxid
    case hearst
}

internal extension OWSSOProvider {
    func parameters(token: String) -> OWNetworkParameters {
        switch self {
        case .janrain:
            return ["provider": "janrain", "janrain_oauth_token": token]
        case .gigya:
            return ["provider": "gigya", "uid": token]
        case .piano:
            return ["provider": "piano", "jwt_token": token]
        case .auth0:
            return ["provider": "auth0", "access_token": token]
        case .foxid:
            return ["provider": "foxid", "jwt_token": token]
        case .hearst:
            return ["provider": "hearst", "session_id": token]
        }
    }
}
