//
//  AccessibilityAnalysisFormalFixes.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 10.03.2026.
//

import Foundation

struct AccessibilityAnalysisFormalFixes: Codable {
    let fixedCode: String
    let fixesApplied: [String]

    enum CodingKeys: String, CodingKey {
        case fixedCode = "fixed_code"
        case fixesApplied = "fixes_applied"
    }
}
