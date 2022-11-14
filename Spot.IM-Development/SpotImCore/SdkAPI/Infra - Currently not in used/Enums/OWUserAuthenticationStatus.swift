//
//  OWUserAuthenticationStatus.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWUserAuthenticationStatus {
    case guest
    case loggedIn(userId: String)
}
#else
enum OWUserAuthenticationStatus {
    case guest
    case loggedIn(userId: String)
}
#endif
