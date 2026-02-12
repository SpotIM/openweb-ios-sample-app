//
//  XCUIElement+Extensions.swift
//  OpenWeb-UITests
//
//  Created by Yonat Sharon on 2026-02-12.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import XCTest

extension XCUIElement {

    @discardableResult
    func waitAndTap(timeout: TimeInterval = 5, file: StaticString = #file, line: UInt = #line) -> Bool {
        let exists = waitForExistence(timeout: timeout)
        XCTAssertTrue(exists, "Element '\(identifier)' should exist", file: file, line: line)
        if exists {
            tap()
        }
        return exists
    }

    @discardableResult
    func waitAndAssertExists(timeout: TimeInterval = 5, message: String? = nil, file: StaticString = #file, line: UInt = #line) -> Bool {
        let exists = waitForExistence(timeout: timeout)
        let errorMessage = message ?? "Element '\(identifier)' should exist"
        XCTAssertTrue(exists, errorMessage, file: file, line: line)
        return exists
    }

    @discardableResult
    func tapIfExists(timeout: TimeInterval = 3) -> Bool {
        if waitForExistence(timeout: timeout) {
            tap()
            return true
        }
        return false
    }

    func ensureSwitch(isOn: Bool, timeout: TimeInterval = 3) {
        guard waitForExistence(timeout: timeout) else { return }
        let currentlyOn = value as? String == "1"
        if currentlyOn != isOn {
            tap()
        }
    }
}
