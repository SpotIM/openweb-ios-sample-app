//
//  OWBasicCompletion.swift
//  SpotImCore
//
//  Created by Alon Haiut on 14/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public typealias OWBasicCompletion = () -> Void
#else
typealias OWBasicCompletion = () -> Void
#endif
