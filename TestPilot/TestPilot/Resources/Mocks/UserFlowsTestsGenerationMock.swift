//
//  UserFlowsTestsGenerationMock.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 04.07.2025.
//

import Foundation

enum UserFlowsTestsGenerationMock {
    static let scenariosResponse = PromptResponse(
        choices: [
            .init(
                message: .init(
                    role: .assistant,
                    content: "- Verify that the \"usernameField\" and \"passwordField\" are initially empty when the view loads.\n- Enter a non-empty string into the \"usernameField\", leave the \"passwordField\" empty, tap the \"loginButton\", and verify that the \"errorMessage\" displays \"Please fill all fields\".\n- Enter a non-empty string into the \"passwordField\", leave the \"usernameField\" empty, tap the \"loginButton\", and verify that the \"errorMessage\" displays \"Please fill all fields\".\n- Enter non-empty strings into both \"usernameField\" and \"passwordField\", tap the \"loginButton\", and verify that the \"errorMessage\" does not appear.\n- Leave both \"usernameField\" and \"passwordField\" empty, tap the \"loginButton\", and verify that the \"errorMessage\" displays \"Please fill all fields\"."
                )
            )
        ]
    )
    
    static let testsResponse = PromptResponse(
        choices: [
            .init(
                message: .init(
                    role: .assistant,
                    content: "```swift\nimport XCTest\n\nfinal class LoginViewUITests: XCTestCase {\n    \n    // Reference to the application\n    var app: XCUIApplication!\n\n    override func setUpWithError() throws {\n        // Initialize the application\n        app = XCUIApplication()\n        // Launch the application before each test\n        app.launch()\n        \n        // In UI tests, it is usually best to stop immediately when a failure occurs.\n        continueAfterFailure = false\n    }\n    \n    func testUsernameAndPasswordFieldsInitiallyEmpty() {\n        // Verify that the \"usernameField\" is initially empty\n        let usernameField = app.textFields[\"usernameField\"]\n        XCTAssertEqual(usernameField.value as? String, \"\")\n\n        // Verify that the \"passwordField\" is initially empty\n        let passwordField = app.secureTextFields[\"passwordField\"]\n        XCTAssertEqual(passwordField.value as? String, \"\")\n    }\n\n    func testErrorMessageWhenPasswordProvidedButUsernameEmpty() {\n        // Enter a non-empty password\n        let passwordField = app.secureTextFields[\"passwordField\"]\n        passwordField.tap()\n        passwordField.typeText(\"password123\")\n\n        // Tap the login button\n        let loginButton = app.buttons[\"loginButton\"]\n        loginButton.tap()\n\n        // Verify the error message is displayed\n        let errorMessage = app.staticTexts[\"errorMessage\"]\n        XCTAssertTrue(errorMessage.exists)\n        XCTAssertEqual(errorMessage.label, \"Please fill all fields\")\n    }\n\n    func testErrorMessageWhenUsernameAndPasswordEmpty() {\n        // Tap the login button with empty fields\n        let loginButton = app.buttons[\"loginButton\"]\n        loginButton.tap()\n\n        // Verify the error message is displayed\n        let errorMessage = app.staticTexts[\"errorMessage\"]\n        XCTAssertTrue(errorMessage.exists)\n        XCTAssertEqual(errorMessage.label, \"Please fill all fields\")\n    }\n}\n"
                )
            )
        ]
    )
}
