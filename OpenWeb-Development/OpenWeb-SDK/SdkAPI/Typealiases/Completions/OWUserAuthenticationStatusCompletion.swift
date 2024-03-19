//
//  OWUserAuthenticationStatusCompletion.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 13/11/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

public typealias OWUserAuthenticationStatusCompletion = (Result<OWUserAuthenticationStatus, OWError>) -> Void
