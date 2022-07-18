//
//  Errors.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

fileprivate struct DebugTools {
    static let servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared
}

enum OWDifferentiatorError: Error {
    case unwrappingOptional
    case preconditionFailed(message: String)
}

func precondition(_ condition: Bool, _ message: @autoclosure() -> String) throws {
    if condition {
        return
    }
    debugFatalError("Precondition failed")

    throw OWDifferentiatorError.preconditionFailed(message: message())
}

func debugFatalError(_ error: Error) {
    debugFatalError("\(error)")
}

func debugFatalError(_ message: String) {
    #if DEBUG
      fatalError(message)
    #else
        DebugTools.servicesProvider.logger().log(level: .error, message, prefix: "RxDataSource")
    #endif
}
