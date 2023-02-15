//
//  SPReadingTracker.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 29/08/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

internal final class SPReadingTracker {
    private var readingStartTime: Date?
    private var accumulatedSeconds: Int = 0

    func startReadingTracking() {
        readingStartTime = Date()
    }

    func stopReadingTracking() {
        logReadingTracking()
        readingStartTime = nil
    }

    private func logReadingTracking() {
        guard let readingStart = readingStartTime else { return }
        let seconds = Date().seconds(fromDate: readingStart)
        accumulatedSeconds += seconds
        if accumulatedSeconds > 0 {
            SPAnalyticsHolder.default.log(event: .reading(accumulatedSeconds), source: .conversation)
        }
    }
}
