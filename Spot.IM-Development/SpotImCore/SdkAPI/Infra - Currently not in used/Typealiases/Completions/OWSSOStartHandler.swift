//
//  OWSSOStartHandler.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

/*
 TODO: Complete the handler type.
 There is an ongoing work on a new user managment approach in the BE
 By the time the iOS refactor will be ready, we might move to that approach
 Complete the handler as needed when it will be time
 */

#if NEW_API
public typealias OWSSOStartHandler = (Result<Void, OWError>) -> Void
#else
typealias OWSSOStartHandler = (Result<Void, OWError>) -> Void
#endif
