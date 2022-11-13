//
//  OWManager+OWAuthentication.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

extension OWManager: OWAuthentication {
    var authentication: OWAuthentication { return authenticationLayer }
}
