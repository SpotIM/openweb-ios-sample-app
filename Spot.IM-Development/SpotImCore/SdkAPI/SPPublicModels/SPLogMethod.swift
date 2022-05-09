//
//  SPLogMethod.swift
//  SpotImCore
//
//  Created by Alon Haiut on 02/05/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

// This entire file can be removed after refactoring prefix to OW

public enum SPLogMethod {
    case nsLog, osLog, file(maxFilesNumber: Int)
}

extension SPLogMethod {
    var toOWPrefix: OWLogMethod {
        switch self {
        case .nsLog:
            return .nsLog
        case .osLog:
            return .osLog
        case .file(let max):
            return .file(maxFilesNumber: max)
        }
    }
}
