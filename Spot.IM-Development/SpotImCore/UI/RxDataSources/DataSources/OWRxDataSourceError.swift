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

enum OWRxDataSourceError: Error {
  case preconditionFailed(message: String)
  case outOfBounds(indexPath: IndexPath)
}

func rxPrecondition(_ condition: Bool, _ message: @autoclosure() -> String) throws {
  if condition {
    return
  }
  rxDebugFatalError("Precondition failed")

  throw OWRxDataSourceError.preconditionFailed(message: message())
}

func rxDebugFatalError(_ error: Error) {
  rxDebugFatalError("\(error)")
}

func rxDebugFatalError(_ message: String) {
    #if DEBUG
      fatalError(message)
    #else
        DebugTools.servicesProvider.logger().log(level: .error, message, prefix: "RxDataSource")
    #endif
}
