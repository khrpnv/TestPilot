//
//  AccessibilityTestsGenerationMock.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 14.09.2025.
//

import Foundation

enum AccessibilityTestsGenerationMock {
    static let response = PromptResponse(
        choices: [
            .init(
                message: .init(
                    role: .assistant,
                    content: "```swift\nimport XCTest\n\nclass LoginViewAccessibilityTests: XCTestCase {\n\n    func testAccessibilityLabels() {\n        let app = XCUIApplication()\n        app.launch()\n\n        let welcomeText = app.staticTexts[\"Welcome to MyBank\"]\n        XCTAssertTrue(welcomeText.exists)\n        XCTAssertTrue(welcomeText.isHittable)\n        \n        let usernameField = app.textFields[\"Username\"]\n        XCTAssertTrue(usernameField.exists)\n        XCTAssertEqual(usernameField.label, \"Username\")\n\n        let passwordField = app.secureTextFields[\"Password\"]\n        XCTAssertTrue(passwordField.exists)\n        XCTAssertEqual(passwordField.label, \"Password\")\n\n        let loginButton = app.buttons[\"arrow.right.circle.fill\"]\n        XCTAssertTrue(loginButton.exists)\n        XCTAssertEqual(loginButton.label, \"Log In\")\n\n        let forgotPasswordButton = app.buttons[\"Forgot Password?\"]\n        XCTAssertTrue(forgotPasswordButton.exists)\n        XCTAssertEqual(forgotPasswordButton.label, \"Forgot Password?\")\n    }\n    \n    func testFocusOrder() {\n        let app = XCUIApplication()\n        app.launch()\n\n        let elementsQuery = app.otherElements\n\n        let welcomeText = elementsQuery.staticTexts[\"Welcome to MyBank\"]\n        let usernameField = elementsQuery.textFields[\"Username\"]\n        let passwordField = elementsQuery.secureTextFields[\"Password\"]\n        let loginButton = elementsQuery.buttons[\"arrow.right.circle.fill\"]\n        let forgotPasswordButton = elementsQuery.buttons[\"Forgot Password?\"]\n        \n        let focusOrder = [welcomeText, usernameField, passwordField, loginButton, forgotPasswordButton]\n\n        for i in 0..<focusOrder.count - 1 {\n            let element = focusOrder[i]\n            let nextElement = focusOrder[i + 1]\n\n            XCTAssertTrue(element.exists)\n\n            element.tap()\n            XCTAssertTrue(nextElement.hasFocus)  // Ensure focus proceeds correctly\n        }\n    }\n    \n    func testDynamicTypeSupport() {\n        let app = XCUIApplication()\n        app.launchArguments.append(\"UI_TEST_DYNAMIC_TYPE\")\n        app.launch()\n\n        let usernameField = app.textFields[\"Username\"]\n        let passwordField = app.secureTextFields[\"Password\"]\n        let loginButton = app.buttons[\"arrow.right.circle.fill\"]\n\n        XCTAssertTrue(usernameField.label.sizeThatFitsUsername.isDynamicTypeSizeAppropriate)\n        XCTAssertTrue(passwordField.label.sizeThatFitsPassword.isDynamicTypeSizeAppropriate)\n        XCTAssertTrue(loginButton.label.sizeThatFitsLogin.isDynamicTypeSizeAppropriate)\n    }\n    \n    func testColorContrast() {\n        let app = XCUIApplication()\n        app.launch()\n\n        let usernameField = app.textFields[\"Username\"]\n        XCTAssertTrue(usernameField.hasSufficientContrast)\n\n        let passwordField = app.secureTextFields[\"Password\"]\n        XCTAssertTrue(passwordField.hasSufficientContrast)\n\n        let loginButton = app.buttons[\"arrow.right.circle.fill\"]\n        XCTAssertTrue(loginButton.hasSufficientContrast)\n    }\n}\n```"
                )
            )
        ]
    )
}
