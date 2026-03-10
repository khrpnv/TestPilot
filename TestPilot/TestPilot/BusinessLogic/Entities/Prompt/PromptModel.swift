//
//  PromptModel.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 10.03.2026.
//

import Foundation

enum PromptModel: String, CaseIterable {
    case gpt4o = "gpt-4o"
    case gpt4_1 = "gpt-4.1"
    case gpt5 = "gpt-5"
    case gpt5mini = "gpt-5-mini"
    case gpt5_4 = "gpt-5.4"
}

// MARK: - Properties
extension PromptModel {
    var title: String {
        switch self {
        case .gpt4o: "GPT 4o"
        case .gpt4_1: "GPT 4.1"
        case .gpt5: "GPT 5"
        case .gpt5mini: "GPT 5 mini"
        case .gpt5_4: "GPT 5.4"
        }
    }
}
