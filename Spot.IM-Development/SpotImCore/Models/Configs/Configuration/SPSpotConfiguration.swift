//
//  SPSpotConfiguration.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/2/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

struct SPSpotConfiguration: Decodable {

    enum CodingKeys: String, CodingKey {

        case apm, conversation, realtime, spotlight, sso, reactions, shared
        case initialization = "init"
        case mobileSdk = "mobile-sdk"

    }

    let apm: SPConfigurationAPM?
    let initialization: SPConfigurationInitialization?
    let conversation: SPConfigurationConversation?
    let realtime: SPConfigurationRealtime?
    let spotlight: SPConfigurationSpotlight?
    let mobileSdk: SPConfigurationSDKStatus
    let sso: SPConfigurationSSO?
    let reactions: SPConfigurationReactions?
    let shared: SPConfigurationShared?
}
