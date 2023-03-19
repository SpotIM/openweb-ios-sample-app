//
//  OWSSOCompletionResponse.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWSSOCompletionResponse: Codable {
    let user: SPUser
}

extension OWSSOCompletionResponse {
    func toSSOCompletionModel() -> OWSSOCompletionModel? {
        guard let userId = user.userId else { return nil }
        return OWSSOCompletionModel(userId: userId)
    }
}
