//
//  Array+Unwrap.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 10/05/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

extension Array {
    func unwrap<T>() -> [T] where Element == T? {
        return filter { $0 != nil }
            .map { $0! }
    }
}
