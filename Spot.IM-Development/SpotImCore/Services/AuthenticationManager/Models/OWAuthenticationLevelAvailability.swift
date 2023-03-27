//
//  OWAuthenticationLevelAvailability.swift
//  SpotImCore
//
//  Created by Alon Haiut on 12/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWAuthenticationLevelAvailability {
    case level(_ level: OWAuthenticationLevel)
    case pending
}
