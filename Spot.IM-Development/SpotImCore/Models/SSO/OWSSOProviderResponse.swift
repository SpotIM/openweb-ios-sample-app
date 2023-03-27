//
//  OWSSOProviderResponse.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWSSOProviderResponse: Codable {
    let user: SPUser
}

extension OWSSOProviderResponse {
    func toSSOProviderModel() -> OWSSOProviderModel? {
        guard let userId = user.userId else { return nil }
        return OWSSOProviderModel(userId: userId)
    }
}
