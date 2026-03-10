//
//  AccessibilityAnalysisService.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 14.09.2025.
//

import Foundation

protocol AccessibilityAnalysisService {
    func generatePurpose(
        code: String,
        component: String,
        completion: @escaping (Result<AccessibilityAnalysisComponentPurpose?, Error>) -> Void
    )
    func performFormalAnalysis(
        code: String,
        component: String,
        completion: @escaping (Result<AccessibilityAnalysisFormalFindings?, Error>) -> Void
    )
}

final class AccessibilityAnalysisServiceImpl: PromptService, AccessibilityAnalysisService {
    func generatePurpose(
        code: String,
        component: String,
        completion: @escaping (Result<AccessibilityAnalysisComponentPurpose?, any Error>) -> Void
    ) {
        let body = PromptRequest(
            model: PromptServiceConfigurations.shared.model.rawValue,
            messages: [
                .init(
                    role: .system,
                    content: AccessibilityAnalysisPrompts.Purpose.systemPrompt
                ),
                .init(
                    role: .user,
                    content: AccessibilityAnalysisPrompts.Purpose.createUserPrompt(input: code)
                )
            ]
        )
        Task {
            let mockedResponse = AccessibilityAnalyzerMock.getMock(for: component)
            
            do {
                let mock = ApplicationConfigurations.useMocks
                let response = mock ? mockedResponse : try await prompt(body: body)
                let output = preparePurposeOutput(response: response.choices.first?.message.content)
                completion(.success(output))
            } catch {
                let response = mockedResponse
                let output = preparePurposeOutput(response: response.choices.first?.message.content)
                completion(.success(output))
            }
        }
    }
    
    func performFormalAnalysis(
        code: String,
        component: String,
        completion: @escaping (Result<AccessibilityAnalysisFormalFindings?, Error>) -> Void
    ) {
        
    }
}

// MARK: - Private
private extension AccessibilityAnalysisServiceImpl {
    func preparePurposeOutput(response: String?) -> AccessibilityAnalysisComponentPurpose? {
        guard let response, let data = response.data(using: .utf8) else {
            return nil
        }
        do {
            let output = try JSONDecoder().decode(AccessibilityAnalysisComponentPurpose.self, from: data)
            return output
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
