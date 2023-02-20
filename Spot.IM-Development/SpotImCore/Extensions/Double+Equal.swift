//
//  Double+Equal.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/10/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

extension Double {
  static func equal(_ lhs: Double, _ rhs: Double, precise value: Int? = nil) -> Bool {
    guard let value = value else {
      return lhs == rhs
    }

    return lhs.precised(value) == rhs.precised(value)
  }

  fileprivate func precised(_ value: Int = 1) -> Double {
    let offset = pow(10, Double(value))
    return (self * offset).rounded() / offset
  }
}
