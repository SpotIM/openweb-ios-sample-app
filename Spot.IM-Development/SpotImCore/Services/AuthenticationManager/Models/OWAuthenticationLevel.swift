//
//  OWAuthenticationLevel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 12/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWAuthenticationLevel {
    case notAutenticated
    case guest
    case loggedIn
}

extension OWAuthenticationLevel {
    // Note that both .notAutenticated and .guest considered to have the same authentication level
    // This is important for correct functionality in guest spots
    var level: Int {
        switch self {
        case .notAutenticated:
            return 0
        case .guest:
            return 0
        case .loggedIn:
            return 2
        }
    }
}
