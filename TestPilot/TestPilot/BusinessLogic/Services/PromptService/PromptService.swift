//
//  PromptService.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 29.06.2025.
//

import Foundation

class PromptService {
    // MARK: - Prompt
    func prompt(body: PromptRequest) async throws -> PromptResponse {
        var request = URLRequest(url: PromptServiceConfigurations.shared.baseUrl)
        request.httpMethod = "POST"
        request.setValue("Bearer \(PromptServiceConfigurations.shared.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(
                domain: "PromptService",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: errorText]
            )
        }

        let decoded = try JSONDecoder().decode(PromptResponse.self, from: data)
        return decoded
    }
}
