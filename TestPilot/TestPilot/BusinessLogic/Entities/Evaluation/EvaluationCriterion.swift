//
//  EvaluationCriterion.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 29.06.2025.
//

import Foundation

enum EvaluationCriterion: String, CaseIterable {
    case strengths = "Strengths"
    case coverage = "Coverage"
    case weaknesses = "Weaknesses"
    case clarityAndMaintainability = "Clarity and Maintainability"
    case suggestions = "Suggestions"
    case accuracy = "Accuracy Score"
    case riskAssessment = "Risk Assessment"
}

// MARK: - Properties
extension EvaluationCriterion {
    static var criteria: String {
        return EvaluationCriterion.allCases.map((\.rawValue)).joined(separator: ", ")
    }
    
    var title: String {
        let emoji: String = switch self {
        case .strengths: "✅"
        case .coverage: "📈"
        case .weaknesses: "⚠️"
        case .clarityAndMaintainability: "✨"
        case .suggestions: "📝"
        case .accuracy: "🎯"
        case .riskAssessment: "🚨"
        }
        return "\(emoji) \(rawValue)"
    }
}
