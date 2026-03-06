//
//  TestsEvaluationService.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 29.06.2025.
//

import Foundation

protocol UnitTestsEvaluationService {
    func evaluate(
        code: String,
        tests: String,
        language: SupportedLanguage,
        completion: @escaping (Result<EvaluationFeedback?, Error>) -> Void
    )
}

final class UnitTestsEvaluationServiceImpl: PromptService, UnitTestsEvaluationService {
    func evaluate(
        code: String,
        tests: String,
        language: SupportedLanguage,
        completion: @escaping (Result<EvaluationFeedback?, Error>) -> Void
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
                        code: code,
                        tests: tests,
                        language: language
                    )
                )
            ]
        )
        Task {
            do {
                let mock = ApplicationConfigurations.useMocks
                let response = mock ? UnitTestsEvaluationMock.response : try await prompt(body: body)
                let output = prepareOutput(text: response.choices.first?.message.content)
                completion(.success(output))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Private
private extension UnitTestsEvaluationServiceImpl {
    func prepareSystemPrompt(language: SupportedLanguage) -> String {
        var prompt: String = ""
        
        switch language {
        case .swift:
            prompt += "You are a senior iOS/macOS engineer and expert in XCTest.\n"
            
        case .python:
            prompt += "You are a senior Python engineer and expert in unittest.\n"
        }
        
        prompt += "Your task is to critically evaluate the quality and coverage of the provided unit tests.\n"
        prompt += "Be thorough, objective, and specific.\n"
        prompt += "Output your feedback grouped under the following categories:\n"
        prompt += "\(EvaluationCriterion.criteria).\n"
        prompt += "For each point, use a clear and concise bullet point where applicable."
        
        return prompt
    }
    
    func prepareUserPrompt(
        code: String,
        tests: String,
        language: SupportedLanguage
    ) -> String {
        return """
        Evaluate the quality of the following unit tests written for this \(language.rawValue) code.
        
        Source Code:
        
        \(code)
        
        Unit Tests:
        
        \(tests)
        
        Please provide your feedback grouped under these categories:
        
        **Strengths:**
        - List positive aspects.
        
        **Coverage:**
        - Describe whether tests cover normal, edge, and error scenarios.
        
        **Weaknesses:**
        - Describe any shortcomings or problems.
        
        **Clarity and Maintainability:**
        - Evaluate test naming, readability, and maintainability.
        
        **Suggestions:**
        - Provide actionable improvements.
        
        **Accuracy Score:**
        - On the next line after this heading, output a single integer from 1 to 5 indicating how accurate and reliable these tests are.
        - Do not include any other text, labels, or formatting on this line—only the integer.
        - Prefix the integer with a hyphen and a space, like this: `- 3`
        
        **Risk Assessment:**
        - Describe the likelihood that bugs or crashes could occur due to insufficient test coverage.
        """
    }
}

// MARK: - Helpers
private extension UnitTestsEvaluationServiceImpl {
    func prepareOutput(text: String?) -> EvaluationFeedback? {
        guard let lines = text?.split(separator: "\n") else {
            return nil
        }
        
        var result: [EvaluationCriterion: [String]] = [:]
        var currentCriterion: EvaluationCriterion?
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmed.hasPrefix("**") && trimmed.hasSuffix(":**") {
                let startIndex = trimmed.index(trimmed.startIndex, offsetBy: 2)
                let endIndex = trimmed.index(trimmed.endIndex, offsetBy: -3)
                let title = trimmed[startIndex..<endIndex].trimmingCharacters(in: .whitespacesAndNewlines)
                
                currentCriterion = EvaluationCriterion(rawValue: title)
                
                if let currentCriterion, result[currentCriterion] == nil {
                    result[currentCriterion] = []
                }
            } else if let criterion = currentCriterion, trimmed.hasPrefix("-") {
                result[criterion, default: []].append(trimmed)
            }
        }
        
        var score: Int = 0
        var feedback: [EvaluationFeedback.Item] = []
        
        for (key, value) in result {
            if key == .accuracy {
                score = Int(value.first?.replacingOccurrences(of: "- ", with: "") ?? "") ?? 0
            } else {
                feedback.append(
                    .init(
                        title: key.title,
                        feedback: value
                    )
                )
            }
        }
        
        return .init(score: score, feedback: feedback)
    }
}
