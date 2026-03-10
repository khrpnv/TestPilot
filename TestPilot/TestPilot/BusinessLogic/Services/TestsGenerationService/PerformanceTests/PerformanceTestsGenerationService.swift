//
//  PerformanceTestsGenerationService.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 28.06.2025.
//

import Foundation

final class PerformanceTestsGenerationServiceImpl: PromptService, TestsGenerationService {
    func generateTests(
        code: String,
        language: SupportedLanguage,
        completion: @escaping (Result<String, any Error>) -> Void
    ) {
        let body = PromptRequest(
            model: PromptServiceConfigurations.shared.model.rawValue,
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
                let response = mock ? PerformanceTestsGenerationMock.response : try await prompt(body: body)
                let output = prepareOutput(response: response, language: language)
                completion(.success(output))
            } catch {
                let response = PerformanceTestsGenerationMock.response
                let output = prepareOutput(response: response, language: language)
                completion(.success(output))
            }
        }
    }
}

// MARK: - Private
private extension PerformanceTestsGenerationServiceImpl {
    func prepareSystemPrompt(language: SupportedLanguage) -> String {
        var prompt: String = """
        You are an expert software engineer specializing in performance engineering and automated testing. 
        Your role is to generate high-quality, production-ready performance and stress tests. 
        You will adapt your approach based on the programming language of the provided code.

        General rules:
        - Focus on clear, idiomatic tests following best practices in the target language.
        - Cover realistic workloads, scalability, concurrency, and edge cases.
        - Always include meaningful assertions in addition to performance checks.
        - Output only the complete unit test code, no explanations or commentary.
        - Wrap the output in triple backticks with the correct language identifier:
        ```\(language.rawValue)
            <performance test code>
        ```
        """
        
        switch language {
        case .swift:
            prompt += """
            - Use XCTest and XCTestPerformance.
            - Use `measure {}` for performance blocks.
            - Use async/await and DispatchQueue when relevant for concurrency tests.
            - Follow Swift and XCTest naming conventions.
            """
            
        case .python:
            prompt += """
            - Prefer pytest with pytest-benchmark if available, otherwise unittest.
            - Use pytest fixtures or decorators for benchmarking.
            - Simulate large inputs and concurrency when applicable.
            - Follow Python testing style conventions.
            """
        }
        
        prompt += "Output only the code, wrapped in triple backticks with the correct language tag."
        
        return prompt
    }
    
    func prepareUserPrompt(
        language: SupportedLanguage,
        code: String
    ) -> String {
        return """
        Here is my source code. 
        Please generate performance and stress tests that push this implementation to its limits. 
        Code:

        \(code)

        Important instructions:
        - Focus on clear, idiomatic tests following best practices in \(language).
        - Cover typical edge cases as appropriate.
        - Output only the complete performance test code.
        - Wrap the output in triple backticks with the \(language.rawValue) identifier, like this:

        ```\(language.rawValue)
        <performance test code here>
        ```
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
