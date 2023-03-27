//
//  OWUserAvailability.swift
//  SpotImCore
//
//  Created by Alon Haiut on 16/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWUserAvailability: Codable {
    case user(_ user: SPUser)
    case notAvailable
}

extension OWUserAvailability: Equatable {
    static func == (lhs: OWUserAvailability, rhs: OWUserAvailability) -> Bool {
        switch (lhs, rhs) {
        case (let .user(lhsUser), let .user(rhsUser)):
            return lhsUser == rhsUser
        case (.notAvailable, .notAvailable):
            return true
        default:
            return false
        }
    }
}
