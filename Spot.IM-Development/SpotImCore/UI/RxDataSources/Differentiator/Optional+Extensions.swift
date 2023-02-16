//
//  Optional+Extensions.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

extension Optional {
    func unwrap() throws -> Wrapped {
        if let unwrapped = self {
            return unwrapped
        } else {
            debugFatalError("Error during unwrapping optional")
            throw OWDifferentiatorError.unwrappingOptional
        }
   }
}
