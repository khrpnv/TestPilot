//
//  AccessibilityTestsGenerationService.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 14.09.2025.
//

import Foundation

final class AccessibilityTestsGenerationServiceImpl: PromptService, TestsGenerationService {
    func generateTests(
        code: String,
        language: SupportedLanguage,
        completion: @escaping (Result<String, any Error>) -> Void
    ) {
        let body = PromptRequest(
            model: Configurations.model,
            messages: [
                .init(
                    role: .system,
                    content: prepareSystemPrompt(language: language)
                ),
                .init(
                    role: .user,
                    content: prepareUserPrompt(
                        language: language,
                        code: code
                    )
                )
            ]
        )
        Task {
            do {
                let mock = ApplicationConfigurations.useMocks
                let response = mock ? AccessibilityTestsGenerationMock.response : try await prompt(body: body)
                let output = prepareOutput(response: response, language: language)
                completion(.success(output))
            } catch {
                let response = AccessibilityTestsGenerationMock.response
                let output = prepareOutput(response: response, language: language)
                completion(.success(output))
            }
        }
    }
}

// MARK: - Private
private extension AccessibilityTestsGenerationServiceImpl {
    func prepareSystemPrompt(language: SupportedLanguage) -> String {
        return """
        You are an expert iOS QA engineer specializing in accessibility testing for Swift and SwiftUI applications.
        Your task is to generate high-quality, idiomatic XCUITest UI tests that validate accessibility features for the provided screen.

        Hard requirements:
        - Use ONLY valid XCTest / XCUITest APIs: XCUIApplication, XCUIElementQuery, XCUIElement, waitForExistence(_:, timeout:), exists, isHittable, isEnabled, label, value.
        - Do NOT invent properties or methods (e.g., hasFocus, hasSufficientContrast, isDynamicTypeSizeAppropriate).
        - Output ONLY complete Swift test code, wrapped in triple backticks with the `swift` identifier.
        - Do NOT include any prose outside the code block.

        Test planning (what to cover):
        1) Accessibility labels & identifiers
           - Query elements by meaningful accessibility labels or identifiers.
           - Assert presence and tappability where applicable (exists/isHittable).
           - If a control appears icon-only in the input, verify a meaningful label is present (or add a TODO comment if missing).
        2) Sensitive information exposure
           - Where relevant, verify raw sensitive data (e.g., full card/account numbers) is NOT exposed via accessible text.
           - Prefer positive queries for masked values; use negative queries for known “raw” identifiers only if provided.
        3) Dynamic Type handling
           - Append a launch argument (e.g., "UI_TEST_LARGE_TEXT") so the app can opt-in to extra-large content size.
           - Re-launch the app when toggling arguments.
           - Under large text mode, assert key elements still exist and are hittable.
           - Add a comment noting that full visual validation requires snapshot testing.
        4) Focus order & color contrast
           - XCTest cannot fully automate VoiceOver focus order or contrast checks.
           - Add TODO comments to remind manual validation with Accessibility Inspector.
        5) Stability & flakiness
           - Use waitForExistence(timeout:) before interacting with elements.
           - Provide explicit failure messages on assertions.
           - Prefer firstMatch or NSPredicate queries if multiple matches are possible.

        Structure & style:
        - Name the test class `<ViewName>AccessibilityTests` if a view name is provided; otherwise `AccessibilityTests`.
        - Implement `setUpWithError()` to set `continueAfterFailure = false` and launch the app with "-uiTesting" (and other arguments as needed).
        - Group related checks into focused test methods, e.g.:
          - testLabelsAndHittability()
          - testDynamicTypeDoesNotBreakKeyElements()
          - testSensitiveDataNotExposed()
        - Include small, reusable helpers inside the test file (e.g., waitForElement, relaunchWithArguments).
        - Provide clear assertion messages with remediation hints.

        If the input lacks identifiers/labels:
        - Use the most reliable query available (e.g., app.buttons["Login"], app.images["..."]). If ambiguous, use `.firstMatch` and add a TODO comment recommending setting an accessibilityIdentifier.
        - Never fabricate identifiers.
        - Wrap the output in triple backticks with `swift` identifier:

        ```swift
            <unit test code here>
        ```
        """
    }
    
    func prepareUserPrompt(
        language: SupportedLanguage,
        code: String
    ) -> String {
        return """
        Here is my SwiftUI/UIKit code. 
        Please generate accessibility unit and UI tests that validate VoiceOver support, labels, focus order, and dynamic text handling. 
        Code:

        \(code)
        """
    }
    
    func prepareOutput(
        response: PromptResponse,
        language: SupportedLanguage
    ) -> String {
        guard var result = response.choices.first?.message.content else {
            return "Something went wrong"
        }
        result = result.replacingOccurrences(of: "```\(language.rawValue)\n", with: "")
        result = result.replacingOccurrences(of: "```", with: "")
        return result
    }
}
