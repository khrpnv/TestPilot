//
//  EvaluationSection.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 29.06.2025.
//

import Foundation

struct EvaluationResult: Identifiable {
    let id = UUID()
    let title: String
    let items: [FeedbackItem]
}
