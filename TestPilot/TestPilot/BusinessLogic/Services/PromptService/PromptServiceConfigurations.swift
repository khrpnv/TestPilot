//
//  PromptServiceConfigurations.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 10.03.2026.
//

import Foundation

final class PromptServiceConfigurations {
    // MARK: - Properties
    let apiKey: String
    let baseUrl: URL
    var model: PromptModel
    
    // MARK: - Shared
    static let shared = PromptServiceConfigurations()
    
    // MARK: - Init
    private init() {
        apiKey = ""
        baseUrl = URL(string: "https://api.openai.com/v1/chat/completions")!
        model = .gpt5_4
    }
}
