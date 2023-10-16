//
//  OWSSOProvider.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWSSOProvider {
    case gigya
    case piano
    case auth0
}
#else
enum OWSSOProvider {
    case gigya
    case piano
    case auth0
}
#endif

internal extension OWSSOProvider {
    func parameters(token: String) -> OWNetworkParameters {
        switch self {
        case .gigya:
            return ["provider": "gigya", "uid": token]
        case .piano:
            return ["provider": "piano", "jwt_token": token]
        case .auth0:
            return ["provider": "auth0", "access_token": token]
        }
    }
}
