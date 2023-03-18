//
//  OWRenewSSOCallback.swift
//  SpotImCore
//
//  Created by Alon Haiut on 18/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public typealias OWRenewSSOCallback = (String, OWBasicCompletion) -> Void
#else
typealias OWRenewSSOCallback = (String, OWBasicCompletion) -> Void
#endif
