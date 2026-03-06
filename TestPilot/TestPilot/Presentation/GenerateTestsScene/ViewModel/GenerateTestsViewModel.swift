//
//  GenerateTestsViewModel.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 28.06.2025.
//

import AppKit
import Foundation

enum GenerateTestsTransition {
    case close
}

final class GenerateTestsViewModel: ViewModel, ObservableObject {
    // MARK: - Properties
    private let type: TestType
    private var sourceCode: String
    private var currentLanguage: SupportedLanguage
    
    // MARK: - Services
    private let testsGenerator: TestsGenerationService
    
    // MARK: - Published
    @Published var inputMode: SourceCodeView.Mode = .select
    @Published var outputMode: SourceCodeView.Mode = .text(content: Strings.GenerateTests.outputPlaceholder)
    @Published var isGenerating: Bool = false
    
    // MARK: - Transition
    private let transitionHandler: (GenerateTestsTransition) -> ()
    
    // MARK: - Init
    init(
        type: TestType,
        testsGenerator: TestsGenerationService,
        transitionHandler: @escaping (GenerateTestsTransition) -> ()
    ) {
        self.type = type
        self.sourceCode = ""
        self.currentLanguage = .swift
        
        self.transitionHandler = transitionHandler
        
        self.testsGenerator = testsGenerator
    }
    
    // MARK: - Get
    func getTitle() -> String {
        return type.title
    }
    
    func getDescription() -> String {
        return type.description
    }
}

// MARK: - Controls
extension GenerateTestsViewModel {
    func openFile() {
        openFile { (content, language) in
            sourceCode = content
            currentLanguage = language
            inputMode = .preview(code: sourceCode, language: currentLanguage.rawValue)
        }
    }
    
    func close() {
        transitionHandler(.close)
    }
    
    func generate() {
        guard !sourceCode.isEmpty else {
            return
        }
        
        isGenerating = true
        
        testsGenerator.generateTests(
            code: sourceCode,
            language: currentLanguage
        ) { (result) in
            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    return
                }
                
                isGenerating = false
                
                switch result {
                case .success(let suggestedCode):
                    outputMode = .preview(code: suggestedCode, language: self.currentLanguage.rawValue)
                    
                case .failure(let error):
                    outputMode = .failure(message: error.localizedDescription)
                }
            }
        }
    }
}
