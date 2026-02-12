//
//  PreConversationLoginPromptUITests.swift
//  OpenWeb-UITests
//
//  Created by Yonat Sharon on 2026-02-12.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import XCTest

final class PreConversationLoginPromptUITests: OpenWebUITestCase {

    func testPreConversationLoginShouldNavigateToFullConversation() throws {
        app.logout()
        app.setSettingsSwitch("login_prompt_switch_id", isOn: true)
        app.navigateToPreConversation()
        tapLoginPrompt()
        app.authenticateWithGenericSSO()
        sleep(1)
        verifyFullConversationIsDisplayed()
        app.tapBackButton()
        sleep(1)
        verifyLoginPromptIsNotDisplayed()
    }

    private func tapLoginPrompt() {
        let loginPrompt = app.otherElements["login_prompt_view_id"]
        app.scrollToElement(loginPrompt)
        loginPrompt.waitAndAssertExists()
        if !app.otherElements["login_prompt_link_id"].tapIfExists() {
            loginPrompt.tap()
        }
    }

    private func verifyFullConversationIsDisplayed(timeout: TimeInterval = 5) {
        let fullConversation = app.otherElements["conversation_view_id"]
        XCTAssertTrue(fullConversation.waitForExistence(timeout: timeout), "Full conversation should be displayed")
    }

    private func verifyLoginPromptIsNotDisplayed() {
        let loginPrompt = app.otherElements["login_prompt_view_id"]
        XCTAssertFalse(loginPrompt.exists, "Login prompt should not be displayed after authentication")
    }
}
