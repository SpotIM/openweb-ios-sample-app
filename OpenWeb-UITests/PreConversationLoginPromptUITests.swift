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
        app.tapBackButton()
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

    private func verifyFullConversationIsDisplayed(timeout: TimeInterval = 10) {
        let fullConversation = app.otherElements["conversation_view_id"]
        fullConversation.waitUntilExists(timeout: timeout)
        XCTAssertTrue(fullConversation.exists, "Full conversation should be displayed")
    }

    private func verifyLoginPromptIsNotDisplayed(timeout: TimeInterval = 10) {
        let preConversation = app.otherElements.matching(
            NSPredicate(format: "identifier BEGINSWITH %@", "pre_conversation_view_")
        ).firstMatch
        preConversation.waitUntilExists(timeout: timeout)
        XCTAssertTrue(preConversation.exists, "Pre-conversation should be displayed")
        let loginPrompt = app.otherElements["login_prompt_view_id"]
        XCTAssertFalse(loginPrompt.exists, "Login prompt should not be displayed after authentication")
    }
}
