//
//  OWTimeMeasure.swift
//  SpotImCore
//
//  Created by Refael Sommer on 02/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

class OWTimeMeasure {
    fileprivate var startTime: DispatchTime = DispatchTime.now()
    fileprivate var endTime: DispatchTime = DispatchTime.now() + 10000 // make sure the first time is not a low diff

    func timeInSeconds() -> Int {
        self.endTime = DispatchTime.now()
        let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
        return Int(Double(nanoTime) / 1_000_000_000)
    }

    func timeInMilliseconds() -> Int {
        self.endTime = DispatchTime.now()
        let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
        return Int(Double(nanoTime) / 1_000_000)
    }

    func start() {
        startTime = DispatchTime.now()
    }
}
