//
//  OWAuthenticationFlowCallback.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

#if NEW_API
public typealias OWAuthenticationFlowCallback = (UINavigationController, OWBasicCompletion) -> Void
#else
typealias OWAuthenticationFlowCallback = (UINavigationController, OWBasicCompletion) -> Void
#endif
