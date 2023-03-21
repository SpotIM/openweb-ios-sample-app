//
//  OWAuthenticationRecoveryResult.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWAuthenticationRecoveryResult {
    case newAuthentication(user: SPUser)
    case authenticationShouldRenew(user: SPUser)
}
