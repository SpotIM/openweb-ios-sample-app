//
//  OWSSOStartResponse.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWSSOStartResponse: Codable {
    let codeB: String
}

extension OWSSOStartResponse {
    func toSSOStartModel() -> OWSSOStartModel {
        return OWSSOStartModel(codeB: codeB)
    }
}
