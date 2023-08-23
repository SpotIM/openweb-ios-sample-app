//
//  OWRealTimeTypingUsers.swift
//  SpotImCore
//
//  Created by Revital Pisman on 06/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWRealTimeTypingUsers: Decodable {
    let users: [OWRealTimeOnlineUser]?
    let count: Int
    let key: String
}
