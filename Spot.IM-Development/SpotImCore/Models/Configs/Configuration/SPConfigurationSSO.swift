//
//  SPConfigurationSSO.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/29/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

struct SPConfigurationSSO: Decodable {

    let login: SPConfigurationLogin?

    struct SPConfigurationLogin: Decodable {

        let secretVar: String?
        let startEndpoint: String?
        let type: String?
    }
}
