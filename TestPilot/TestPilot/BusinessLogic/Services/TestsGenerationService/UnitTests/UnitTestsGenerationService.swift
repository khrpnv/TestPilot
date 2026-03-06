//
//  UnitTestsGenerationService.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 28.06.2025.
//

import Foundation

final class UnitTestsGenerationServiceImpl: PromptService, TestsGenerationService {
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
                let response = mock ? UnitTestsGenerationMock.response : try await prompt(body: body)
                let output = prepareOutput(response: response, language: language)
                completion(.success(output))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Private
private extension UnitTestsGenerationServiceImpl {
    func prepareSystemPrompt(language: SupportedLanguage) -> String {
        var prompt: String = ""
        
        switch language {
        case .swift:
            prompt += "You are a senior iOS/macOS engineer generating high-quality Swift unit tests.\n"
            prompt += "Always produce idiomatic XCTest code.\n"
            
        case .python:
            prompt += "You are a senior Python engineer generating high-quality Python unit tests.\n"
            prompt += "Always produce idiomatic tests using unittest.\n"
        }
        
        prompt += "Output only the code, wrapped in triple backticks with the correct language tag."
        
        return prompt
    }
    
    func prepareUserPrompt(
        language: SupportedLanguage,
        code: String
    ) -> String {
        let framework: String
        
        switch language {
        case .swift:
            framework = "XCTest"
            
        case .python:
            framework = "unittest"
        }
        
        return """
        Generate high-quality unit tests for the following \(language.rawValue) code:

        \(code)

        Use the \(framework) testing framework.

        Important instructions:
        - Focus on clear, idiomatic tests following best practices in \(language).
        - Cover typical edge cases as appropriate.
        - Output only the complete unit test code.
        - Wrap the output in triple backticks with the \(language.rawValue) identifier, like this:

        ```\(language.rawValue)
        <unit test code here>
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
