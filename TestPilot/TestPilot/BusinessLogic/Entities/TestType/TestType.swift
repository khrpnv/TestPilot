//
//  TestType.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 14.09.2025.
//

import Foundation

enum TestType {
    case unitTests
    case performanceTests
    case accessibilityTests
}

// MARK: - Properties
extension TestType {
    var title: String {
        switch self {
        case .unitTests:
            return Strings.GenerateTests.UnitTests.title
            
        case .performanceTests:
            return Strings.GenerateTests.PerformanceTests.title
            
        case .accessibilityTests:
            return Strings.GenerateTests.AccessibilityTests.title
        }
    }
    
    var description: String {
        switch self {
        case .unitTests:
            return Strings.GenerateTests.UnitTests.description
            
        case .performanceTests:
            return Strings.GenerateTests.PerformanceTests.description
            
        case .accessibilityTests:
            return Strings.GenerateTests.AccessibilityTests.description
        }
    }
}
