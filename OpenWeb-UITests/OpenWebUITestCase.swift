//
//  OpenWebUITestCase.swift
//  OpenWeb-UITests
//
//  Created by Yonat Sharon on 12/02/2026.
//

import XCTest

class OpenWebUITestCase: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        app.navigateToTestAPI()
    }

    override func tearDownWithError() throws {
        app = nil
    }
}
