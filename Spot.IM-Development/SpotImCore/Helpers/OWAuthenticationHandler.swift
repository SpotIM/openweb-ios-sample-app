//
//  AuthenticationHandler.swift
//  Spot.IM-Core
//
//  Created by Eugene on 9/2/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

typealias AuthHandler = (_ isAuthenticated: Bool) -> Void

final class OWAuthenticationHandler {

    var authHandler: AuthHandler?

}
