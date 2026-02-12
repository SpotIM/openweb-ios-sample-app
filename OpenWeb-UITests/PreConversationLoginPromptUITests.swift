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
        verifyFullConversationIsDisplayed()
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
        let fullConversationExists = app.otherElements["conversation_view_id"].waitForExistence(timeout: timeout)
        let loginPromptStillVisible = app.otherElements["login_prompt_view_id"].exists && app.otherElements["login_prompt_view_id"].isHittable
        let preConversationStillVisible = app.otherElements["pre_conversation_summary_view_id"].exists

        XCTAssertTrue(fullConversationExists, "After authentication, full conversation should be displayed")
        XCTAssertFalse(loginPromptStillVisible, "Login prompt should not be visible after authentication")
        XCTAssertFalse(preConversationStillVisible, "Pre-conversation should not be visible after authentication")
    }
}
