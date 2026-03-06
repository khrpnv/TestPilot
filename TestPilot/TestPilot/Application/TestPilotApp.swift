//
//  TestPilotApp.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 28.06.2025.
//

import SwiftUI
import Combine

@main
struct TestPilotApp: App {
    // MARK: - Container
    private let container: TestPilotAppContainer = TestPilotAppContainerImpl()
    
    // MARK: - Route
    enum Route {
        case welcome
        case generate(type: TestType)
        case evaluate
        case userFlows
        case accessibility
    }
    
    // MARK: - Properties
    @State var route: Route = .welcome
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            switch route {
            case .welcome:
                welcomeScene()
                
            case .generate(let type):
                generateTestsScene(type: type)
                
            case .evaluate:
                evaluateTestsScene()
                
            case .userFlows:
                userFlowsTestsScene()
                
            case .accessibility:
                accessibilityAnalyzerScene()
            }
        }
    }
}

// MARK: - Private
private extension TestPilotApp {
    func welcomeScene() -> some View {
        let viewModel = WelcomeViewModel { (transition) in
            switch transition {
            case .generate(let type):
                route = .generate(type: type)
                
            case .evaluate:
                route = .evaluate
                
            case .userFlows:
                route = .userFlows
                
            case .accessibility:
                route = .accessibility
            }
        }
        return WelcomeView(viewModel: viewModel)
    }
    
    func generateTestsScene(type: TestType) -> some View {
        let viewModel = GenerateTestsViewModel(
            type: type,
            testsGenerator: container.getTestsGenerationService(type: type)
        ) { (transition) in
            switch transition {
            case .close:
                route = .welcome
            }
        }
        let view = GenerateTestsView(viewModel: viewModel)
        return fullScreenView(content: view)
    }
    
    func evaluateTestsScene() -> some View {
        let viewModel = EvaluateTestsViewModel(unitTestsEvaluator: container.unitTestsEvaluator) { (transition) in
            switch transition {
            case .close:
                route = .welcome
            }
        }
        let view = EvaluateTestsView(viewModel: viewModel)
        return fullScreenView(content: view)
    }
    
    func userFlowsTestsScene() -> some View {
        let viewModel = UserFlowsTestsViewModel(userFlowsTestsGenerator: container.userFlowsTestsGenerator) { (transition) in
            switch transition {
            case .close:
                route = .welcome
            }
        }
        let view = UserFlowsTestsView(viewModel: viewModel)
        return fullScreenView(content: view)
    }
    
    func accessibilityAnalyzerScene() -> some View {
        let viewModel = AccessibilityAnalyzerViewModel(
            accessibilityAnalyzer: container.accessibilityAnalyzer,
            accessibilityReportGenerator: container.accessibilityReportGenerator
        ) { (transition) in
            switch transition {
            case .close:
                route = .welcome
            }
        }
        let view = AccessibilityAnalyzerView(viewModel: viewModel)
        return fullScreenView(content: view)
    }
}

// MARK: - Helpers
private extension TestPilotApp {
    func fullScreenView(content: some View) -> some View {
        return content.background {
            WindowAccessor { (window) in
                window?.setFrame(NSScreen.main!.visibleFrame, display: true)
            }
        }
    }
}
