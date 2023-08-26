//
//  RandomGenerator.swift
//  OpenWebCoreTests
//
//  Created by Alon Haiut on 15/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

class RandomGenerator {
    func randomInt(lowerValue: Int = 0, upperValue: Int = 999_999) -> Int {
        return Int.random(in: lowerValue ... upperValue)
    }
}
