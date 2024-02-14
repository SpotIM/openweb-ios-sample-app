//
//  OWOpenProfileResult.swift
//  SpotImCore
//
//  Created by Alon Shprung on 04/12/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

enum OWOpenProfileResult {
    case openProfile(type: OWOpenProfileType)
    case authenticationTriggered
}
