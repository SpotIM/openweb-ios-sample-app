//
//  SPConfigurationRealtime.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/2/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

struct SPConfigurationRealtime: Decodable {

    let cacheTtlSeconds: Int?
    let enableOnlineUsers: Bool?
    let noOnlinePollingInterval: Int?
    let onlineUserTtlMinutes: Int?
    let onlineUsersBatchSize: Int?
    let pollingInterval: Int?
    let readBatchSize: Int?
    let startTimeoutMilliseconds: Int?
    let typingUserTtlSeconds: Int?
    let typingUsersBatchSize: Int?
    let usersTypingInterval: Int?

}
