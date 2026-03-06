//
//  PromptResponse.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 29.06.2025.
//

import Foundation

struct PromptResponse: Decodable {
    // MARK: - Choice
    struct Choice: Decodable {
        let message: PromptMessage
    }
    
    // MARK: - Properties
    let choices: [Choice]
}
