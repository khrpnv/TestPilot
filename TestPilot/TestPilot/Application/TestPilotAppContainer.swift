//
//  TestPilotAppContainer.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 29.06.2025.
//

import Foundation

protocol TestPilotAppContainer {
    // MARK: - Properties
    var unitTestsEvaluator: UnitTestsEvaluationService { get }
    var userFlowsTestsGenerator: UserFlowsTestsGenerationService { get }
    var accessibilityAnalyzer: AccessibilityAnalysisService { get }
    var accessibilityReportGenerator: AccessibilityReportGenerationService { get }
    
    // MARK: - Funcs
    func getTestsGenerationService(type: TestType) -> TestsGenerationService
}

final class TestPilotAppContainerImpl: TestPilotAppContainer {
    // MARK: - Properties
    lazy var unitTestsEvaluator: UnitTestsEvaluationService = setupUnitTestsEvaluator()
    lazy var userFlowsTestsGenerator: UserFlowsTestsGenerationService = setupUserFlowsTestsGenerationService()
    lazy var accessibilityAnalyzer: AccessibilityAnalysisService = setupAccessibilityAnalyzer()
    lazy var accessibilityReportGenerator: AccessibilityReportGenerationService = setupAccessibilityReportGenerator()
    
    // MARK: - Funcs
    func getTestsGenerationService(type: TestType) -> TestsGenerationService {
        switch type {
        case .unitTests:
            return UnitTestsGenerationServiceImpl()
            
        case .performanceTests:
            return PerformanceTestsGenerationServiceImpl()
            
        case .accessibilityTests:
            return AccessibilityTestsGenerationServiceImpl()
        }
    }
}

// MARK: - Setup
private extension TestPilotAppContainerImpl {
    func setupUnitTestsEvaluator() -> UnitTestsEvaluationService {
        return UnitTestsEvaluationServiceImpl()
    }
    
    func setupUserFlowsTestsGenerationService() -> UserFlowsTestsGenerationService {
        return UserFlowsTestsGenerationServiceImpl()
    }
    
    func setupAccessibilityAnalyzer() -> AccessibilityAnalysisService {
        return AccessibilityAnalysisServiceImpl()
    }
    
    func setupAccessibilityReportGenerator() -> AccessibilityReportGenerationService {
        return AccessibilityReportGenerationServiceImpl()
    }
}
