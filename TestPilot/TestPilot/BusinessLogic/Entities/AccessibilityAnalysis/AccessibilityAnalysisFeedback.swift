//
//  AccessibilityAnalysisFeedback.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 14.09.2025.
//

import SwiftUI
import Foundation

struct AccessibilityAnalysisFeedback: Decodable {
    let view: String
    let score: Int
    let issues: [Issue]
}

// MARK: - Issues
extension AccessibilityAnalysisFeedback {
    struct Issue: Decodable {
        let id: String
        let type: String
        let line: Int
        let description: String
        let suggestion: String
        let severity: Severity
        let manualCheck: Bool
    }
}

// MARK: - Severity
extension AccessibilityAnalysisFeedback {
    enum Severity: String, Decodable, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }
}
