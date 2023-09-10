//
//  OWRealTimeTypingUsers.swift
//  SpotImCore
//
//  Created by Revital Pisman on 06/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWRealTimeTypingUsers: Decodable {
    let users: [OWRealTimeOnlineUser]
    let count: Int
    let key: String

    enum CodingKeys: String, CodingKey {
        case users
        case count
        case key
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        // Attempt to decode the users using a failable wrapper. If not present or fails, use an empty array.
        if let failableUsers = try values.decodeIfPresent([OWFailableWrapperDecodable<OWRealTimeOnlineUser>].self, forKey: .users) {
            users = failableUsers.map { $0.wrappedValue }.unwrap()
        } else {
            users = []
        }

        count = try values.decode(Int.self, forKey: .count)
        key = try values.decode(String.self, forKey: .key)
    }
}
