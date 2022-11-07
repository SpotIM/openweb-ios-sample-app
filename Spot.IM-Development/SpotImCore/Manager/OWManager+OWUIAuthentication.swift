//
//  OWManager+OWUIAuthentication.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

extension OWManager: OWUIAuthentication {
    var authentication: OWUIAuthentication { return authenticationLayer }
}
