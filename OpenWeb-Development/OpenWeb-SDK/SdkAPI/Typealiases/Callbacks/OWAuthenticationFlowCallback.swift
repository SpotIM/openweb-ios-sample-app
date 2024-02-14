//
//  OWAuthenticationFlowCallback.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/11/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit

public typealias OWAuthenticationFlowCallback = (OWRouteringMode, @escaping OWBasicCompletion) -> Void
