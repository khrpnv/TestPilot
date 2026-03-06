//
//  UserFlowsTestsViewModel.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 04.07.2025.
//

import Foundation

enum UserFlowsTestsTransition {
    case close
}

final class UserFlowsTestsViewModel: ViewModel, ObservableObject {
    // MARK: - Properties
    private var sourceCode: String
    
    // MARK: - Services
    private let userFlowsTestsGenerator: UserFlowsTestsGenerationService
    
    // MARK: - Published
    @Published var inputMode: SourceCodeView.Mode = .select
    @Published var scenarios: [ScenarioRowModel]
    @Published var isGeneratingUserFlows: Bool = false
    @Published var isGeneratingTests: Bool = false
    @Published var outputMode: SourceCodeView.Mode = .text(content: Strings.GenerateTests.outputPlaceholder)
    @Published var preview: Bool = false
    
    // MARK: - Transition
    var transitionHandler: (UserFlowsTestsTransition) -> ()
    
    // MARK: - Init
    init(
        userFlowsTestsGenerator: UserFlowsTestsGenerationService,
        transitionHandler: @escaping (UserFlowsTestsTransition) -> ()
    ) {
        self.sourceCode = ""
        self.scenarios = []
        
        self.userFlowsTestsGenerator = userFlowsTestsGenerator
        
        self.transitionHandler = transitionHandler
    }
}

// MARK: - Controls
extension UserFlowsTestsViewModel {
    func openFile() {
        openFile { (content, language) in
            sourceCode = content
            inputMode = .preview(code: sourceCode, language: language.rawValue)
            preview = true
        }
    }
    
    func close() {
        transitionHandler(.close)
    }
    
    func generateScenarios() {
        guard !sourceCode.isEmpty else {
            return
        }
        
        isGeneratingUserFlows = true
        
        userFlowsTestsGenerator.generateUserFlows(
            code: sourceCode,
        ) { (result) in
            DispatchQueue.main.async {
                self.isGeneratingUserFlows = false
                
                switch result {
                case .success(let output):
                    self.scenarios = output.map({ .init(title: $0) })
                    
                case .failure(let failure):
                    self.scenarios = [.init(title: failure.localizedDescription)]
                }
            }
        }
    }
    
    func generateTests() {
        let selectedScenarios = scenarios.filter({ $0.isSelected })
        
        guard !sourceCode.isEmpty, !selectedScenarios.isEmpty else {
            return
        }
        
        isGeneratingTests = true
        
        userFlowsTestsGenerator.generateTests(
            code: sourceCode,
            scenarios: selectedScenarios.map(\.title),
        ) { (result) in
            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    return
                }
                
                isGeneratingTests = false
                
                switch result {
                case .success(let suggestedCode):
                    outputMode = .preview(code: suggestedCode, language: SupportedLanguage.swift.rawValue)
                    
                case .failure(let failure):
                    outputMode = .failure(message: failure.localizedDescription)
                }
            }
        }
    }
}
