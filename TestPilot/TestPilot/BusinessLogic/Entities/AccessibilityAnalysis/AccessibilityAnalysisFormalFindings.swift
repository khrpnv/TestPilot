//
//  AccessibilityAnalysisFormalFindings.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 10.03.2026.
//

import Foundation

struct AccessibilityAnalysisFormalFindings: Codable {
    let score: Int
    let formalFindings: [FormalFinding]
    let analysisConfidence: AnalysisConfidence

    enum CodingKeys: String, CodingKey {
        case score = "score"
        case formalFindings = "formal_findings"
        case analysisConfidence = "analysis_confidence"
    }
}

// MARK: - Details
extension AccessibilityAnalysisFormalFindings {
    struct FormalFinding: Codable {
        let id: String
        let category: Category
        let severity: Severity
        let confidence: Confidence
        let evidence: String
        let whyItMatters: String
        let suggestedFix: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case category
            case severity
            case confidence
            case evidence
            case whyItMatters = "why_it_matters"
            case suggestedFix = "suggested_fix"
        }
    }
    
    enum Severity: String, Codable {
        case low
        case medium
        case high
    }
    
    enum Confidence: String, Codable {
        case high
    }
    
    enum AnalysisConfidence: String, Codable {
        case high
        case medium
    }
    
    enum Category: String, Codable {
        case primaryInteractionGesture = "PRIMARY_INTERACTION_GESTURE"
        case tappableContainerWithoutRole = "TAPPABLE_CONTAINER_WITHOUT_ROLE"
        case meaningfulImageWithoutSemantics = "MEANINGFUL_IMAGE_WITHOUT_SEMANTICS"
        case decorativeContentNotHidden = "DECORATIVE_CONTENT_NOT_HIDDEN"
        case customControlMissingSemantics = "CUSTOM_CONTROL_MISSING_SEMANTICS"
        case formControlMissingLabel = "FORM_CONTROL_MISSING_LABEL"
        case stateNotExposed = "STATE_NOT_EXPOSED"
        case colorOnlyStateIndication = "COLOR_ONLY_STATE_INDICATION"
        case misusedAccessibilityHidden = "MISUSED_ACCESSIBILITY_HIDDEN"
        case nestedInteractiveElements = "NESTED_INTERACTIVE_ELEMENTS"
        case missingAccessibilityValue = "MISSING_ACCESSIBILITY_VALUE"
        
        func formatted() -> String {
            switch self {
            case .primaryInteractionGesture:
                return "Primary interaction gesture"
            case .tappableContainerWithoutRole:
                return "Tappable container without role"
            case .meaningfulImageWithoutSemantics:
                return "Meaningful image without semantics"
            case .decorativeContentNotHidden:
                return "Decorative content not hidden"
            case .customControlMissingSemantics:
                return "Custom control missing semantics"
            case .formControlMissingLabel:
                return "Form control missing label"
            case .stateNotExposed:
                return "State not exposed"
            case .colorOnlyStateIndication:
                return "Color-only state indication"
            case .misusedAccessibilityHidden:
                return "Misused accessibility hidden"
            case .nestedInteractiveElements:
                return "Nested interactive elements"
            case .missingAccessibilityValue:
                return "Missing accessibility value"
            }
        }
    }
}

// MARK: - Helpers
extension AccessibilityAnalysisFormalFindings {
    func toJSON() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        do {
            let data = try encoder.encode(self)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }
}
