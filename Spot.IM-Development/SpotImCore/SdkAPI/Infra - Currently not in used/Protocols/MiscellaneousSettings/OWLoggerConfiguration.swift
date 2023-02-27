//
//  OWLoggerConfiguration.swift
//  SpotImCore
//
//  Created by Alon Haiut on 21/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public protocol OWLoggerConfiguration {
    var level: OWLogLevel { get set }
    var methods: [OWLogMethod] { get set }
}
#else
protocol OWLoggerConfiguration {
    var level: OWLogLevel { get set }
    var methods: [OWLogMethod] { get set }
}
#endif
