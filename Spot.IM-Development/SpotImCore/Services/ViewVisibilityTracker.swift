//
//  ViewVisibilityTracker.swift
//  SpotImCore
//
//  Created by Rotem Itzhak on 26/05/2020.
//  Copyright © 2020 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

protocol ViewVisibilityDelegate: AnyObject {
    func viewDidBecomeVisible(view: UIView)
    func viewDidDisappear(view: UIView)
}

internal final class ViewVisibilityTracker {
    private enum State {
        case shutdown, initialized, started, stopped
    }

    private weak var delegate: ViewVisibilityDelegate?
    private weak var view: UIView?
    private var visibilityTimer: Timer?

    private var lastVisibilityState: Bool = false
    private var state: State = .shutdown

    deinit {
        shutdown()
    }

    func setup(view: UIView, delegate: ViewVisibilityDelegate) {
        if state != .shutdown {
            shutdown()
        }

        self.view = view
        self.delegate = delegate

        setNotificationObservers()

        state = .initialized
    }

    func shutdown() {
        guard state != .shutdown else {
            return
        }

        self.stopTracking()
        lastVisibilityState = false
        self.view = nil
        self.delegate = nil
        NotificationCenter.default.removeObserver(self)

        state = .shutdown
    }

    func stopTracking() {
        guard state == .started else {
            return
        }

        visibilityTimer?.invalidate()
        visibilityTimer = nil

        state = .stopped
    }

    func startTracking() {
        guard state != .shutdown else {
            return
        }

        startVisibilityTracking()
        state = .started
    }

    private func setNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appStopped),
            name: UIApplication.willResignActiveNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appStopped),
            name: UIApplication.willTerminateNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
    }

    @objc
    private func appStopped() {
        guard state == .started else {
            return
        }

        if let view = self.view {
            self.lastVisibilityState = false
            delegate?.viewDidDisappear(view: view)
        }
        stopTracking()
    }

    @objc
    private func appMovedToForeground() {
        guard state == .stopped else {
            return
        }

        startTracking()
    }

    private func startVisibilityTracking() {
        guard state != .started, state != .shutdown else {
            return
        }

        visibilityTimer?.invalidate()
        visibilityTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (timer) in
            guard timer.isValid, let self = self, let view = self.view else {
                return
            }

            // view appeared on the screen
            if view.isVisibleToUser && !self.lastVisibilityState {
                self.lastVisibilityState = true
                self.delegate?.viewDidBecomeVisible(view: view)
            } else if !view.isVisibleToUser && self.lastVisibilityState {
                self.lastVisibilityState = false
                self.delegate?.viewDidDisappear(view: view)
            }
        })

        visibilityTimer?.tolerance = 0.5
        RunLoop.current.add(visibilityTimer!, forMode: .common)
    }
}
