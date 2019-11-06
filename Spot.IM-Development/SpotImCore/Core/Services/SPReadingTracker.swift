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

    private weak var view: UIView?
    private var visibilityTimer: Timer?
    private var readingStartTime: Date?
    private var accumulatedSeconds: Int = 0

    private var spotShowed = false

    deinit {
        stopAllAndCleanUp()
    }

    internal func setupTracking(for view: UIView) {
        self.view = view
        setupVisibilityTracking()
    }

    private func setupVisibilityTracking() {
        visibilityTimer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(checkVisibility),
            userInfo: nil,
            repeats: true)
        visibilityTimer?.tolerance = 0.5
        RunLoop.current.add(visibilityTimer!, forMode: .common)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appTerminated),
            name: UIApplication.willTerminateNotification,
            object: nil)
    }

    @objc
    private func appMovedToBackground() {
        pauseAll()
        SPAnalyticsHolder.default.log(event: .appClosed, source: .mainPage)
    }

    // TODO: (Fedin) respond to this case
    @objc
    private func appTerminated() {
        logReadingTracking()
    }

    @objc
    private func checkVisibility(timer: Timer) {
        guard let windowHeight = view?.window?.frame.size.height,
            let absoluteY = view?.convert(CGPoint.zero, to: nil).y,
            timer.isValid else {
            return
        }

        // view appeared on the screen
        if absoluteY < windowHeight, !spotShowed {

            spotShowed = true

            SPAnalyticsHolder.default.log(event: .viewed, source: .conversation) // should be triggered ONCE

            startReadingTracking()

        // view disappeared
        } else if absoluteY > windowHeight, spotShowed {

            spotShowed = false

            stopReadingTracking()
        }
    }

    private func stopVisibilityTracking() {
        visibilityTimer?.invalidate()
        visibilityTimer = nil
    }

    private func startReadingTracking() {
        readingStartTime = Date()
    }

    private func logReadingTracking() {
        guard let readingStart = readingStartTime else { return }
        let seconds = Date().seconds(fromDate: readingStart)
        accumulatedSeconds += seconds
        if accumulatedSeconds > 0 {
            SPAnalyticsHolder.default.log(event: .reading(accumulatedSeconds), source: .conversation)
        }
    }

    private func stopReadingTracking() {
        logReadingTracking()
        readingStartTime = nil
    }

    private func pauseAll() {
        logReadingTracking()
        stopVisibilityTracking()
    }

    private func stopAllAndCleanUp() {
        stopVisibilityTracking()
        stopReadingTracking()
        NotificationCenter.default.removeObserver(self)
    }
}
