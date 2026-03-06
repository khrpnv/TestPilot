//
//  UserFlowsTestsGenerationService.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 04.07.2025.
//

import Foundation

protocol UserFlowsTestsGenerationService {
    func generateUserFlows(
        code: String,
        completion: @escaping (Result<[String], any Error>) -> Void
    )
    func generateTests(
        code: String,
        scenarios: [String],
        completion: @escaping (Result<String, Error>) -> Void
    )
}

final class UserFlowsTestsGenerationServiceImpl: PromptService, UserFlowsTestsGenerationService {
    func generateUserFlows(
        code: String,
        completion: @escaping (Result<[String], any Error>) -> Void
    ) {
        let body = PromptRequest(
            model: Configurations.model,
            messages: [
                .init(
                    role: .system,
                    content: prepareSystemPromptForUserFlows()
                ),
                .init(
                    role: .user,
                    content: prepareUserPromptForUserFlows(code: code)
                )
            ]
        )
        Task {
            do {
                let mock = ApplicationConfigurations.useMocks
                let response = mock ? UserFlowsTestsGenerationMock.scenariosResponse : try await prompt(body: body)
                let output = prepareScenariosOutput(response: response)
                completion(.success(output))
            } catch {
                let response = UserFlowsTestsGenerationMock.scenariosResponse
                let output = prepareScenariosOutput(response: response)
                completion(.success(output))
            }
        }
    }
    
    func generateTests(
        code: String,
        scenarios: [String],
        completion: @escaping (Result<String, any Error>) -> Void
    ) {
        let body = PromptRequest(
            model: Configurations.model,
            messages: [
                .init(
                    role: .system,
                    content: prepareSystemPromptForTests()
                ),
                .init(
                    role: .user,
                    content: prepareUserPromptForTests(
                        code: code,
                        scenarios: scenarios
                    )
                )
            ]
        )
        Task {
            do {
                let mock = ApplicationConfigurations.useMocks
                let response = mock ? UserFlowsTestsGenerationMock.testsResponse : try await prompt(body: body)
                let output = prepareTestsOutput(response: response)
                completion(.success(output))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Private
private extension UserFlowsTestsGenerationServiceImpl {
    func prepareSystemPromptForUserFlows() -> String {
        return """
        You are an expert iOS QA engineer who writes clear, realistic UI test scenarios for SwiftUI applications. You analyze SwiftUI code to propose actionable test cases that verify correct behavior.
        """
    }
    
    func prepareUserPromptForUserFlows(code: String) -> String {
        return """
        Analyze the following SwiftUI view code and suggest clear, realistic UI test scenarios that verify the view behaves correctly.

        SwiftUI Code:

        \(code)

        For each scenario, describe the specific steps a user would take and what the test should verify. Make sure each scenario is unambiguous so it can be used directly to generate XCUITest code.

        Output the scenarios as a bullet list. Each scenario should be one sentence describing the action and the expected result. Do not include any explanation or introduction—only the list of scenarios.
        """
    }
    
    func prepareSystemPromptForTests() -> String {
        return """
        You are an expert iOS QA automation engineer who writes clean, production-quality UI test code in Swift using the XCUITest framework. You follow best practices, including using accessibility identifiers for locating elements and writing clear, maintainable tests.
        """
    }
    
    func prepareUserPromptForTests(
        code: String,
        scenarios: [String]
    ) -> String {
        return """
        Generate Swift UI tests using the XCUITest framework based on the following SwiftUI component and the list of test scenarios.

        SwiftUI Component Code:

        \(code)

        Test Scenarios:

        \(scenarios.joined(separator: "\n"))

        For each scenario, create a complete test method in a single Swift test class. Use descriptive function names that reflect the scenario. Ensure the tests:

        - Use accessibility identifiers when interacting with UI elements.
        - Contain assertions that verify expected behavior.
        - Follow XCUITest conventions.

        Important:

        Wrap the entire output in triple backticks with the swift identifier, like this:

        ```swift
        <unit test code here>
        """
    }
    
    func prepareScenariosOutput(response: PromptResponse) -> [String] {
        guard let result = response.choices.first?.message.content else {
            return ["Something went wrong"]
        }
        return result.split(separator: "\n").map({ String($0).replacingOccurrences(of: "-", with: "") })
    }
    
    func prepareTestsOutput(response: PromptResponse) -> String {
        guard var result = response.choices.first?.message.content else {
            return "Something went wrong"
        }
        result = result.replacingOccurrences(of: "```swift\n", with: "")
        result = result.replacingOccurrences(of: "```", with: "")
        return result
    }
}
