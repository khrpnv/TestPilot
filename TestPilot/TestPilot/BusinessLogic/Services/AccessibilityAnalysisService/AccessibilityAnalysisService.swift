//
//  AccessibilityAnalysisService.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 14.09.2025.
//

import Foundation

protocol AccessibilityAnalysisService {
    func analyze(
        code: String,
        completion: @escaping (Result<AccessibilityAnalysisFeedback?, Error>) -> Void
    )
}

final class AccessibilityAnalysisServiceImpl: PromptService, AccessibilityAnalysisService {
    func analyze(
        code: String,
        completion: @escaping (Result<AccessibilityAnalysisFeedback?, any Error>) -> Void
    ) {
        let body = PromptRequest(
            model: Configurations.model,
            messages: [
                .init(
                    role: .system,
                    content: prepareSystemPrompt()
                ),
                .init(
                    role: .user,
                    content: prepareUserPrompt(code: code)
                )
            ]
        )
        Task {
            do {
                let mock = ApplicationConfigurations.useMocks
                let response = mock ? AccessibilityAnalyzerMock.response : try await prompt(body: body)
                let output = prepareOutput(text: response.choices.first?.message.content)
                completion(.success(output))
            } catch {
                let response = AccessibilityAnalyzerMock.response
                let output = prepareOutput(text: response.choices.first?.message.content)
                completion(.success(output))
            }
        }
    }
}

// MARK: - Private
private extension AccessibilityAnalysisServiceImpl {
    func prepareSystemPrompt() -> String {
        return """
        You are an expert iOS accessibility engineer specializing in SwiftUI.
        Your task is to analyze SwiftUI code and return ONLY a strict JSON report of accessibility issues.

        Output rules:
        - Return ONLY valid JSON (UTF-8), no markdown fences, no prose, no comments.
        - Do not include trailing commas or NaN/Infinity values.
        - If something is unknown (e.g., line numbers), use sentinel values as specified.

        JSON schema (must match exactly):
        {
          "view": "<String: SwiftUI view name if provided or detectable, otherwise 'Unknown'>",
          "issues": [
            {
              "id": "<String: stable unique id per issue, e.g., 'Label-1'>",
              "type": "<String: one of ['Label','DynamicType','Contrast','TouchTarget','Navigation','SensitiveData']>",
              "line": <Int: 1-based line number if detectable, otherwise -1>,
              "description": "<String: concise problem summary>",
              "suggestion": "<String: concrete SwiftUI fix or guidance>",
              "severity": "<String: one of ['Low','Medium','High']>",
              "manualCheck": <Boolean: true if requires human validation, else false>
            }
          ],
          "score": <Int: overall accessibility score from 1 to 10>
        }

        Scoring guideline (deterministic):
        - Start at 10.
        - Subtract 3 for each High, 2 for each Medium, 1 for each Low.
        - Clamp to [1,10].

        Severity guidance:
        - High: Missing/ambiguous labels on interactive controls, sensitive data exposed to accessibility APIs, unlabeled icon-only buttons.
        - Medium: Dynamic Type not supported, likely illogical navigation order, important elements not hittable.
        - Low: Possible small touch targets (<44x44pt), potential color contrast issues, minor labeling polish.

        Detection guidance:
        - Prefer concrete, verifiable findings (e.g., icon-only Button without .accessibilityLabel).
        - Line numbers: if code lines are provided, compute 1-based line; otherwise set to -1.
        - View name: derive from declarations like `struct <Name>: View`; if not found, set to "Unknown".
        - Navigation order: XCTest cannot fully automate; flag as Medium with manualCheck=true if layout suggests a risk.
        - Contrast: cannot be computed statically; if colors suggest low contrast, flag as Low with manualCheck=true.
        - Touch target size: if likely too small (e.g., small Image in Button without padding), flag as Low with manualCheck=true.
        - Sensitive data: balances, PAN/card numbers, IBAN, names, addresses exposed via accessibility without necessity → High.

        IDs:
        - Make IDs stable and readable per run: "<Type>-<increment>", e.g., "Label-1", "DynamicType-2".

        If no issues are found:
        - Return "issues": [] and "score": 10.

        Important:
        - Use ONLY real SwiftUI concepts; do NOT invent APIs or facts.
        - The response must be a single JSON object exactly matching the schema.

        """
    }
    
    func prepareUserPrompt(code: String) -> String {
        return """
        Analyze the following SwiftUI screen for accessibility issues and return ONLY a JSON object matching the schema. Do not add any text outside the JSON.

        Code:
        
        \(code)
        """
    }
}

// MARK: - Helpers
private extension AccessibilityAnalysisServiceImpl {
    func prepareOutput(text: String?) -> AccessibilityAnalysisFeedback? {
        guard let text, let data = text.data(using: .utf8) else {
            return nil
        }
        do {
            let output = try JSONDecoder().decode(AccessibilityAnalysisFeedback.self, from: data)
            return output
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
