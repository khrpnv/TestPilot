//
//  PromptRequest.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 29.06.2025.
//

import Foundation

struct PromptRequest: Codable {
    let model: String
    let messages: [PromptMessage]
}
