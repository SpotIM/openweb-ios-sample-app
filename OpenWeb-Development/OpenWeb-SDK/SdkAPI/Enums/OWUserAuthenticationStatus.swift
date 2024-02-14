//
//  OWUserAuthenticationStatus.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/11/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

public enum OWUserAuthenticationStatus {
    case notAutenticated
    case guest
    case ssoLoggedIn(userId: String)
}
