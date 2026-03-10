//
//  EvaluateTestsViewModel.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 29.06.2025.
//

import AppKit
import Foundation

enum EvaluateTestsTransition {
    case close
}

final class EvaluateTestsViewModel: ViewModel, ObservableObject {
    // MARK: - Properties
    private var unitTests: String
    private var sourceCode: String
    private var currentLanguage: SupportedLanguage
    
    // MARK: - Services
    private let unitTestsEvaluator: UnitTestsEvaluationService
    
    // MARK: - Published
    @Published var codeInputMode: SourceCodeView.Mode = .select
    @Published var testsInputMode: SourceCodeView.Mode = .select
    @Published var evaluationResults: [EvaluationResult] = []
    @Published var accuracyScore: Int = 0
    @Published var isEvaluating: Bool = false
    
    // MARK: - Transition
    private let transitionHandler: (EvaluateTestsTransition) -> ()
    
    // MARK: - Init
    init(
        unitTestsEvaluator: UnitTestsEvaluationService,
        transitionHandler: @escaping (EvaluateTestsTransition) -> ()
    ) {
        self.unitTests = ""
        self.sourceCode = ""
        self.currentLanguage = .swift
        
        self.transitionHandler = transitionHandler
        
        self.unitTestsEvaluator = unitTestsEvaluator
    }
}

// MARK: - Controls
extension EvaluateTestsViewModel {
    func close() {
        transitionHandler(.close)
    }
    
    func openFile(code: Bool) {
        openFile { (content, _, language) in
            currentLanguage = language
            
            if code {
                sourceCode = content
                codeInputMode = .preview(code: sourceCode, language: currentLanguage.rawValue)
            } else {
                unitTests = content
                testsInputMode = .preview(code: unitTests, language: currentLanguage.rawValue)
            }
        }
    }
    
    func evaluate() {
        guard !sourceCode.isEmpty, !unitTests.isEmpty else {
            return
        }
        
        isEvaluating = true
        
        unitTestsEvaluator.evaluate(
            code: sourceCode,
            tests: unitTests,
            language: currentLanguage
        ) { (result) in
            DispatchQueue.main.async { [weak self] in
                self?.isEvaluating = false
                
                switch result {
                case .success(let output):
                    self?.accuracyScore = output?.score ?? 0
                    self?.evaluationResults = output?.feedback.map {
                        EvaluationResult(
                            title: $0.title,
                            items: $0.feedback.map({ .init(text: $0) })
                        )
                    } ?? []
                    
                case .failure(let error):
                    self?.evaluationResults = [
                        .init(
                            title:  Strings.EvaluateTests.errorTitle,
                            items: [.init(text: error.localizedDescription)]
                        )
                    ]
                }
            }
        }
    }
}
