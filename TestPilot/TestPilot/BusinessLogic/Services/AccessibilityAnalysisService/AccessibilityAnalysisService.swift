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
        purpose: AccessibilityAnalysisComponentPurpose?,
        completion: @escaping (Result<AccessibilityAnalysisFormalFindings?, Error>) -> Void
    )
    func performFormalFixes(
        code: String,
        component: String,
        formalFindings: AccessibilityAnalysisFormalFindings?,
        completion: @escaping (Result<AccessibilityAnalysisFormalFixes?, Error>) -> Void
    )
    func performHeuristicAnalysis(
        code: String,
        component: String,
        purpose: AccessibilityAnalysisComponentPurpose?,
        completion: @escaping (Result<AccessibilityAnalysisHeuristicFindings?, Error>) -> Void
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
        
        let mockedResponse = AccessibilityAnalyzerMock.getPurposeMock(for: component)
        
        executeAnalysis(
            requestBody: body,
            mockedResponse: mockedResponse,
            completion: completion
        )
    }
    
    func performFormalAnalysis(
        code: String,
        component: String,
        purpose: AccessibilityAnalysisComponentPurpose?,
        completion: @escaping (Result<AccessibilityAnalysisFormalFindings?, Error>) -> Void
    ) {
        let body = PromptRequest(
            model: PromptServiceConfigurations.shared.model.rawValue,
            messages: [
                .init(
                    role: .system,
                    content: AccessibilityAnalysisPrompts.FormalChecks.systemPrompt
                ),
                .init(
                    role: .user,
                    content: AccessibilityAnalysisPrompts.FormalChecks.createUserPrompt(
                        input: code,
                        purpose: purpose
                    )
                )
            ]
        )
        
        let mockedResponse = AccessibilityAnalyzerMock.getFormalChecksMock(for: component)
        
        executeAnalysis(
            requestBody: body,
            mockedResponse: mockedResponse,
            completion: completion
        )
    }
    
    func performFormalFixes(
        code: String,
        component: String,
        formalFindings: AccessibilityAnalysisFormalFindings?,
        completion: @escaping (Result<AccessibilityAnalysisFormalFixes?, any Error>) -> Void
    ) {
        let body = PromptRequest(
            model: PromptServiceConfigurations.shared.model.rawValue,
            messages: [
                .init(
                    role: .system,
                    content: AccessibilityAnalysisPrompts.FormalFixes.systemPrompt
                ),
                .init(
                    role: .user,
                    content: AccessibilityAnalysisPrompts.FormalFixes.createUserPrompt(
                        input: code,
                        formalFindings: formalFindings
                    )
                )
            ]
        )
        
        let mockedResponse = AccessibilityAnalyzerMock.getFormalFixesMock(for: component)
        
        executeAnalysis(
            requestBody: body,
            mockedResponse: mockedResponse,
            completion: completion
        )
    }
    
    func performHeuristicAnalysis(
        code: String,
        component: String,
        purpose: AccessibilityAnalysisComponentPurpose?,
        completion: @escaping (Result<AccessibilityAnalysisHeuristicFindings?, any Error>) -> Void
    ) {
        let body = PromptRequest(
            model: PromptServiceConfigurations.shared.model.rawValue,
            messages: [
                .init(
                    role: .system,
                    content: AccessibilityAnalysisPrompts.HeuristicChecks.systemPrompt
                ),
                .init(
                    role: .user,
                    content: AccessibilityAnalysisPrompts.HeuristicChecks.createUserPrompt(
                        input: code,
                        purpose: purpose
                    )
                )
            ]
        )
        
        let mockedResponse = AccessibilityAnalyzerMock.getHeuristicChecksMock(for: component)
        
        executeAnalysis(
            requestBody: body,
            mockedResponse: mockedResponse,
            completion: completion
        )
    }
}

// MARK: - Private
private extension AccessibilityAnalysisServiceImpl {
    func executeAnalysis<T: Decodable>(
        requestBody: PromptRequest,
        mockedResponse: PromptResponse,
        completion: @escaping (Result<T?, Error>) -> Void
    ) {
        Task {
            do {
                let response: PromptResponse
                
                if ApplicationConfigurations.useMocks {
                    let delay = UInt64.random(in: 3_000_000_000...5_000_000_000)
                    try await Task.sleep(nanoseconds: delay)
                    response = mockedResponse
                } else {
                    response = try await prompt(body: requestBody)
                }
                
                let output: T? = prepareOutput(from: response.choices.first?.message.content)
                completion(.success(output))
            } catch {
                let fallbackOutput: T? = prepareOutput(from: mockedResponse.choices.first?.message.content)
                completion(.success(fallbackOutput))
            }
        }
    }
    
    func prepareOutput<T: Decodable>(from response: String?, as type: T.Type = T.self) -> T? {
        guard var response else {
            return nil
        }
        
        response = response
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
        
        guard let data = response.data(using: .utf8) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print(error)
            return nil
        }
    }
}
