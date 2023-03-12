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
    var level: Int {
        switch self {
        case .notAutenticated:
            return 0
        case .guest:
            return 1
        case .loggedIn:
            return 2
        }
    }
}
