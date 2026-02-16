//
//  XCUIApplication+SampleApp.swift
//  OpenWeb-UITests
//
//  Created by Yonat Sharon on 12/02/2026.
//

import XCTest

extension XCUIApplication {

    func navigateToTestAPI() {
        buttons["test_api_btn_id"].waitAndTap()
        otherElements["test_api_vc_id"].waitAndAssertExists()
    }

    func logout() {
        buttons["auth_bar_item_id"].waitAndTap()
        otherElements["authentication_playground_new_api_vc_id"].waitAndAssertExists()
        swipeUp()
        buttons["btn_logout"].tapIfExists()
        waitForCheckmark("lbl_logout_status_symbol")
        tapBackButton()
    }

    func navigateToPreConversation() {
        buttons["btn_ui_flows_id"].waitAndTap()
        otherElements["uiflows_vc_id"].waitAndAssertExists()
        buttons["btn_pre_conversation_push_mode_id"].waitAndTap()
    }

    func setSettingsSwitch(_ identifier: String, isOn: Bool) {
        buttons["settings_bar_item_id"].waitAndTap()
        otherElements["settings_vc_id"].waitAndAssertExists()
        let settingsSwitch = switches[identifier]
        scrollToElement(settingsSwitch)
        settingsSwitch.ensureSwitch(isOn: isOn)
        tapBackButton()
    }

    func authenticateWithGenericSSO(timeout: TimeInterval = 10) {
        buttons["btn_generic_sso_authenticate"].waitAndTap(timeout: timeout)
        waitForCheckmark("lbl_generic_sso_status_symbol")
        waitForElementToDisappear("authentication_playground_new_api_vc_id")
    }
}
