//
//  OWUserAuthenticationStatusCompletion.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public typealias OWUserAuthenticationStatusCompletion = (Result<OWUserAuthenticationStatus, OWError>) -> Void
#else
typealias OWUserAuthenticationStatusCompletion = (Result<OWUserAuthenticationStatus, OWError>) -> Void
#endif
