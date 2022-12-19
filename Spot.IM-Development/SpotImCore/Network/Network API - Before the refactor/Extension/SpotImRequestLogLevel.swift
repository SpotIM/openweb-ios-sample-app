//
//  LogLevel.swift
//  SpotImCore
//
//  Created by Rotem Itzhak on 01/01/2020.
//  Copyright © 2020 Spot.IM. All rights reserved.
//

internal enum SpotImRequestLogLevel: Int {
    /// none Don't write any logs
    case none
    
    /// simple - Write Request + Response lines with the following structure:
    /// - [Request] METHOD URL
    /// - [Response] METHOD RETURN_CODE URL CALL_TIME
    case simple
    
    /// medium - In addition to .simple, write critical headers and json data
    case medium
    
    /// verbose - In addition to .medium, write all headers
    case verbose
}
