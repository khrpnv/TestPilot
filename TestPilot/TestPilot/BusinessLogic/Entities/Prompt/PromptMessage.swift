//
//  PromptMessage.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 29.06.2025.
//

import Foundation

struct PromptMessage: Codable {
    // MARK: - Role
    enum Role: String, Codable {
        case system
        case user
        case assistant
    }
    
    // MARK: - Properties
    let role: Role
    let content: String
}
