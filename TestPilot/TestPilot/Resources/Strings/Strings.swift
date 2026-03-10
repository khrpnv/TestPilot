//
//  Strings.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 28.06.2025.
//

import Foundation

enum Strings {
    enum Shared {
        static let openFileButtonTitle = "Open File"
    }
    
    enum Welcome {
        static let title = "TestPilot"
        static let description = "TestPilot helps you write better Swift and Python code by harnessing AI. Effortlessly generate high-quality unit tests, create automated UI tests for real user scenarios, and evaluate your existing tests to ensure they’re complete, reliable, and maintainable."
        static let createTestsButtonTitle = "Create Unit Tests"
        static let evaluateTestsButtonTitle = "Evaluate Unit Tests"
        static let generateUITestsButtonTitle = "Generate User Flow Tests"
        static let performanceTestsButtonTitle = "Create Performance Tests"
        static let accessibilityTestsButtonTitle = "Create Accessibility Tests"
        static let accessibilityAnalyzerButtonTitle = "Accessibility Analyzer"
    }
    
    enum GenerateTests {
        enum UnitTests {
            static let title = "Generate Unit Tests"
            static let description = "This mode allows you to generate unit tests automatically based on the Swift or Python code you provide. To get started, select a file containing the source code you want to create tests for."
        }
        
        enum PerformanceTests {
            static let title = "Generate Performance & Stress Tests"
            static let description = "This mode analyzes your Swift or Python code and automatically generates performance and stress test cases. It helps you validate that your code runs efficiently under load, handles edge cases gracefully, and meets performance expectations. To get started, select a file containing the source code you want to evaluate."
        }
        
        enum AccessibilityTests {
            static let title = "Accessibility Tests"
            static let description = "This mode analyzes your SwiftUI or UIKit code and automatically generates accessibility-focused test cases. It ensures that your app mobile accessibility standards by validating VoiceOver support, element labels, focus order, dynamic text scaling, and sensitive data protection. To get started, select a file containing the source code you want to evaluate."
        }
        
        static let generateButtonTitle = "Generate"
        static let outputPlaceholder = "Generated tests will appear here."
    }
    
    enum EvaluateTests {
        static let title = "Evaluate Unit Tests"
        static let description = "This tool reviews your existing unit tests and provides detailed feedback about their quality, completeness, and potential improvements."
        static let sourceCodeTitle = "Source Code"
        static let unitTestsTitle = "Unit Tests"
        static let evaluateButtonTitle = "Evaluate"
        static let noFeedbackTitle = "No feedback yet."
        static let riskAssessmentTitle = "Risk Assessment:"
        static let errorTitle = "Failure"
    }
    
    enum UserFlowsTests {
        static let title = "Generate User Flow Tests"
        static let description = "This tool generates UI tests for your SwiftUI components. Paste your code, choose or describe user flows, and receive ready-to-run XCUITests that verify your app works as intended."
        static let generateScenariosButtonTitle = "Generate Scenarios"
        static let generateUITestsButtonTitle = "Generate UI Tests"
        static let noScenariosPlaceholder = "No scenarios defined yet."
        static let sourceCodeTitle = "Source Code"
        static let testScenariosTitle = "Test Scenarios"
        static let testsTitle = "UI Tests"
    }
    
    enum AccessibilityAnalyzer {
        static let title = "Accessibility Analyzer"
        static let description = "This mode reviews your SwiftUI code to detect common accessibility issues before testing. The analyzer provides actionable suggestions to improve inclusivity and ensure compliance with mobile accessibility standards. To get started, select a file containing the source code you want to analyze."
        static let sourceCodeTitle = "Source Code"
        static let analyzeButtonTitle = "Analyze Accessibility"
        static let viewTitle = "View:"
        static let scoreTitle = "Score:"
        static let noIssuesFound = "✅ No issues found"
        static let noResultsPlaceholder = "Analysis results will be available here"
        static let lineTitle = "Line:"
        static let suggestionTitle = "Suggestion:"
        static let severityTitle = "Severity:"
        static let manualCheckNeeded = "⚠️ Requires manual check"
        static let exportButtonTitle = "Export"
        static let purposeButtonTitle = "Analyze Purpose"
    }
}
