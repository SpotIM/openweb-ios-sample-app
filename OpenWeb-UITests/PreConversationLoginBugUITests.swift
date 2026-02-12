import XCTest

final class PreConversationLoginBugUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testPreConversationLoginShouldNavigateToFullConversation() throws {
        navigateToTestAPI()
        logout()
        enableShowLoginPrompt()
        navigateToPreConversation()
        authenticateFromLoginPrompt()
        verifyFullConversationIsDisplayed()
    }

    private func navigateToTestAPI() {
        let exploreButton = app.buttons["test_api_btn_id"]
        XCTAssertTrue(exploreButton.waitForExistence(timeout: 5), "Explore button should exist on main page")
        exploreButton.tap()

        let testAPIView = app.otherElements["test_api_vc_id"]
        XCTAssertTrue(testAPIView.waitForExistence(timeout: 5), "Test API screen should appear")
    }

    private func logout() {
        let authKeyButton = app.buttons["auth_bar_item_id"]
        XCTAssertTrue(authKeyButton.waitForExistence(timeout: 5), "Auth button should exist")
        authKeyButton.tap()

        let authPlayground = app.otherElements["authentication_playground_new_api_vc_id"]
        XCTAssertTrue(authPlayground.waitForExistence(timeout: 5), "Authentication playground should appear")

        app.swipeUp()

        let logoutButton = app.buttons["btn_logout"]
        if logoutButton.waitForExistence(timeout: 3) {
            logoutButton.tap()
            sleep(1)
        }

        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    private func enableShowLoginPrompt() {
        let settingsButton = app.buttons["settings_bar_item_id"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5), "Settings button should exist")
        settingsButton.tap()

        let settingsTitle = app.staticTexts["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 5), "Settings screen should appear")

        for _ in 0..<5 {
            app.swipeUp()
        }

        let loginPromptSwitch = app.switches["login_prompt_switch_id"]
        if loginPromptSwitch.waitForExistence(timeout: 3) {
            if loginPromptSwitch.value as? String == "0" {
                loginPromptSwitch.tap()
            }
        }

        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    private func navigateToPreConversation() {
        let uiFlowsButton = app.buttons["btn_ui_flows_id"]
        XCTAssertTrue(uiFlowsButton.waitForExistence(timeout: 5), "UI Flows button should exist")
        uiFlowsButton.tap()

        let uiFlowsView = app.otherElements["uiflows_vc_id"]
        XCTAssertTrue(uiFlowsView.waitForExistence(timeout: 5), "UI Flows screen should appear")

        let preConversationButton = app.buttons["btn_pre_conversation_push_mode_id"]
        XCTAssertTrue(preConversationButton.waitForExistence(timeout: 5), "Pre Conversation button should exist")
        preConversationButton.tap()

        for _ in 0..<3 {
            app.swipeUp()
        }

        let loginPromptView = app.otherElements["login_prompt_view_id"]
        XCTAssertTrue(loginPromptView.waitForExistence(timeout: 10), "Login prompt should be visible in pre-conversation when user is logged out and Show Login Prompt is enabled")
    }

    private func authenticateFromLoginPrompt() {
        let loginPromptLink = app.otherElements["login_prompt_link_id"]
        if loginPromptLink.waitForExistence(timeout: 5) {
            loginPromptLink.tap()
        } else {
            let loginPromptView = app.otherElements["login_prompt_view_id"]
            loginPromptView.tap()
        }

        let authenticateButton = app.buttons["btn_generic_sso_authenticate"]
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 10), "Authentication screen should appear with Authenticate button")
        authenticateButton.tap()

        sleep(2)
    }

    private func verifyFullConversationIsDisplayed() {
        let conversationView = app.otherElements["conversation_view_id"]
        let fullConversationExists = conversationView.waitForExistence(timeout: 10)

        let loginPromptView = app.otherElements["login_prompt_view_id"]
        let loginPromptStillVisible = loginPromptView.exists && loginPromptView.isHittable

        let preConversationSummary = app.otherElements["pre_conversation_summary_view_id"]
        let preConversationStillVisible = preConversationSummary.exists

        XCTAssertTrue(fullConversationExists, "OW-37653: After authentication from pre-conversation login prompt, full conversation should be displayed")
        XCTAssertFalse(loginPromptStillVisible, "OW-37653: Login prompt should not be visible after successful authentication - user should see full conversation, not pre-conversation")
        XCTAssertFalse(preConversationStillVisible, "OW-37653: Pre-conversation summary should not be visible - user should navigate to full conversation after authentication")
    }
}
