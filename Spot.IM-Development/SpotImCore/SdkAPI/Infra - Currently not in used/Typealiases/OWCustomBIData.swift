//
//  OWCustomBIData.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 15/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public typealias OWCustomBIData = [String: Codable]
#else
typealias OWCustomBIData = [String: Codable]
#endif
