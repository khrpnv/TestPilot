//
//  AccessibilityAnalysisFormalFindings.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 10.03.2026.
//

import Foundation

struct AccessibilityAnalysisHeuristicFindings: Codable {
    let score: Int
    let heuristicFindings: [HeuristicFinding]
    let runtimeValidationRecommended: [RuntimeValidationRecommendation]
    let analysisConfidence: Confidence
    
    enum CodingKeys: String, CodingKey {
        case score
        case heuristicFindings = "heuristic_findings"
        case runtimeValidationRecommended = "runtime_validation_recommended"
        case analysisConfidence = "analysis_confidence"
    }
}

// MARK: - Details
extension AccessibilityAnalysisHeuristicFindings {
    struct HeuristicFinding: Codable {
        let id: String
        let category: FindingCategory
        let severity: Severity
        let confidence: Confidence
        let rationale: String
        let potentialUserImpact: String
        let suggestedImprovement: String

        enum CodingKeys: String, CodingKey {
            case id
            case category
            case severity
            case confidence
            case rationale
            case potentialUserImpact = "potential_user_impact"
            case suggestedImprovement = "suggested_improvement"
        }
    }

    struct RuntimeValidationRecommendation: Codable {
        let area: ValidationArea
        let reason: String
    }

    enum Severity: String, Codable {
        case low
        case medium
        case high
    }

    enum Confidence: String, Codable {
        case low
        case medium
        case high
    }

    enum ValidationArea: String, Codable {
        case focusOrder = "focus_order"
        case dynamicType = "dynamic_type"
        case spokenOutput = "spoken_output"
        case rotorBehavior = "rotor_behavior"
        case touchTarget = "touch_target"
        case contrast
        
        func formatted() -> String {
            switch self {
            case .focusOrder:
                return "Focus order"
            case .dynamicType:
                return "Dynamic type"
            case .spokenOutput:
                return "Spoken output"
            case .rotorBehavior:
                return "Rotor behavior"
            case .touchTarget:
                return "Touch target"
            case .contrast:
                return "Contrast"
            }
        }
    }
    
    enum FindingCategory: String, Codable {
        case semanticMatch = "semantic_match"
        case labelClarity = "label_clarity"
        case actionMeaning = "action_meaning"
        case stateCommunication = "state_communication"
        case grouping
        case verbosity
        case interactionModel = "interaction_model"
        case financialClarity = "financial_clarity"
        case cognitiveLoad = "cognitive_load"
        
        func formatted() -> String {
            switch self {
            case .semanticMatch:
                return "Semantic match"
            case .labelClarity:
                return "Label clarity"
            case .actionMeaning:
                return "Action meaning"
            case .stateCommunication:
                return "State communication"
            case .grouping:
                return "Grouping"
            case .verbosity:
                return "Verbosity"
            case .interactionModel:
                return "Interaction model"
            case .financialClarity:
                return "Financial clarity"
            case .cognitiveLoad:
                return "Cognitive load"
            }
        }
    }
}
