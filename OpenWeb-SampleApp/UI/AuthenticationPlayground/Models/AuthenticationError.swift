//
//  AuthenticationError.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 11/05/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

enum AuthenticationError: Error {
    case startSSOCodeAMissing
    case completeSSOFailed
    case JWTSSOFailed
    case userLoginFailed
    case codeBFailed
}
