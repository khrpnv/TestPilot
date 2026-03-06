//
//  EvaluationFeedback.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 04.07.2025.
//

import Foundation

struct EvaluationFeedback {
    // MARK: - Item
    struct Item {
        let title: String
        let feedback: [String]
    }
    
    // MARK: - Properties
    let score: Int
    let feedback: [Item]
}
