//
//  AccessibilityAnalysisFeedback.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 14.09.2025.
//

import SwiftUI
import Foundation

struct AccessibilityAnalysisFeedback {
    let view: String
    let formal: AccessibilityAnalysisFormalFindings?
    let heuristic: AccessibilityAnalysisHeuristicFindings?
    
    // MARK: - Init
    init(
        view: String,
        formal: AccessibilityAnalysisFormalFindings?,
        heuristic: AccessibilityAnalysisHeuristicFindings?
    ) {
        self.view = view
        self.formal = formal
        self.heuristic = heuristic
    }
}
