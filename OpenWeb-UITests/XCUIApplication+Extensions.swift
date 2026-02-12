//
//  XCUIApplication+Extensions.swift
//  OpenWeb-UITests
//
//  Created by Yonat Sharon on 12/02/2026.
//

import XCTest

extension XCUIApplication {

    func tapBackButton() {
        navigationBars.buttons.element(boundBy: 0).tap()
    }

    func scrollToElement(_ element: XCUIElement, maxSwipes: Int = 10) {
        var swipeCount = 0
        while !element.isHittable && swipeCount < maxSwipes {
            swipeUp()
            swipeCount += 1
        }
    }

    func waitForCheckmark(_ identifier: String, timeout: TimeInterval = 10) {
        let statusSymbol = staticTexts[identifier]
        let predicate = NSPredicate(format: "label CONTAINS '✅'")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: statusSymbol)
        _ = XCTWaiter.wait(for: [expectation], timeout: timeout)
    }

    func waitForElementToDisappear(_ identifier: String, timeout: TimeInterval = 5) {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: otherElements[identifier]
        )
        _ = XCTWaiter.wait(for: [expectation], timeout: timeout)
    }
}
