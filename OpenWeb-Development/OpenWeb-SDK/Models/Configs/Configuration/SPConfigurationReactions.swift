//
//  SPConfigurationReactions.swift
//  OpenWebSDK
//
//  Created by Eugene on 8/29/19.
//  Copyright © 2019 OpenWeb. All rights reserved.
//

import Foundation

struct SPConfigurationReactions: Decodable {

    let reactionsAssetsPath: SPConfigurationReactionAssets?

    struct SPConfigurationReactionAssets: Decodable {

        let baseUrl: String?
    }
}
