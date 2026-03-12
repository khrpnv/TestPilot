//
//  AccessibilityAnalyzerViewModel.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 29.06.2025.
//

import AppKit
import SwiftUI
import Foundation

enum AccessibilityAnalyzerTransition {
    case close
}

final class AccessibilityAnalyzerViewModel: ViewModel, ObservableObject {
    // MARK: - Properties
    private var component: String
    private var sourceCode: String
    private var currentLanguage: SupportedLanguage
    private var formalFindings: AccessibilityAnalysisFormalFindings?
    private var formalFixes: AccessibilityAnalysisFormalFixes?
    private var heuristicFindings: AccessibilityAnalysisHeuristicFindings?
    
    // MARK: - Services
    private let accessibilityAnalyzer: AccessibilityAnalysisService
    private let accessibilityReportGenerator: AccessibilityReportGenerationService
    
    // MARK: - Published
    @Published var inputMode: SourceCodeView.Mode = .select
    @Published var preview: Image?
    
    @Published var purposeAnalyzing: Bool = false
    @Published var purposeDetails: AccessibilityAnalysisComponentPurpose?
    
    @Published var isAnalyzing: Bool = false
    @Published var feedback: AccessibilityAnalysisFeedback?
    
    // MARK: - Transition
    private let transitionHandler: (EvaluateTestsTransition) -> ()
    
    // MARK: - Init
    init(
        accessibilityAnalyzer: AccessibilityAnalysisService,
        accessibilityReportGenerator: AccessibilityReportGenerationService,
        transitionHandler: @escaping (EvaluateTestsTransition) -> ()
    ) {
        self.component = ""
        self.sourceCode = ""
        self.currentLanguage = .swift
        
        self.transitionHandler = transitionHandler
        
        self.accessibilityAnalyzer = accessibilityAnalyzer
        self.accessibilityReportGenerator = accessibilityReportGenerator
    }
}

// MARK: - Controls
extension AccessibilityAnalyzerViewModel {
    func close() {
        transitionHandler(.close)
    }
    
    func openFile() {
        openFile { (content, fileName, language) in
            sourceCode = content
            currentLanguage = language
            preview = Image(fileName)
            component = fileName
            inputMode = .preview(code: sourceCode, language: currentLanguage.rawValue)
        }
    }
    
    func exportReport() {
        guard let feedback else {
            return
        }
        accessibilityReportGenerator.export(
            feedback: feedback,
            presentingWindow: nil
        ) { (_) in
            print("REPORT EXPORT FINISHED")
        }
    }
    
    func exportCode() {
        exportFiles() { (_) in
            print("FILE EXPORT FINISHED")
        }
    }
    
    func analyzePurpose() {
        guard !sourceCode.isEmpty else {
            return
        }
        
        purposeAnalyzing = true
        
        accessibilityAnalyzer.generatePurpose(
            code: sourceCode,
            component: component
        ) { (result) in
            DispatchQueue.main.async { [weak self] in
                self?.purposeAnalyzing = false
                
                switch result {
                case .success(let details):
                    self?.purposeDetails = details
                    
                case .failure(let failure):
                    print(failure)
                }
            }
        }
    }
    
    func analyze() {
        guard !sourceCode.isEmpty else {
            return
        }
        
        isAnalyzing = true
        
        accessibilityAnalyzer.performFormalAnalysis(
            code: sourceCode,
            component: component,
            purpose: purposeDetails
        ) { [weak self] (formalAnalysisResults) in
            guard let self else {
                return
            }
            if case let .success(findings) = formalAnalysisResults {
                formalFindings = findings
            }
            
            accessibilityAnalyzer.performFormalFixes(
                code: sourceCode,
                component: component,
                formalFindings: formalFindings
            ) { [weak self] (formalFixesResults) in
                guard let self else {
                    return
                }
                if case let .success(fixes) = formalFixesResults {
                    formalFixes = fixes
                }
                
                accessibilityAnalyzer.performHeuristicAnalysis(
                    code: formalFixes?.fixedCode ?? sourceCode,
                    component: component,
                    purpose: purposeDetails
                ) { [weak self] (result) in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else {
                            return
                        }
                        
                        if case let .success(findings) = result {
                            heuristicFindings = findings
                        }
                        
                        isAnalyzing = false
                        
                        feedback = .init(
                            view: component,
                            formal: formalFindings,
                            heuristic: heuristicFindings
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Private
private extension AccessibilityAnalyzerViewModel {
    func exportFiles(completion: @escaping (Result<[URL], Error>) -> Void) {
        let firstFileName = component
        let firstFileExtension = "swift"
        let firstText = formalFixes?.fixedCode ?? sourceCode
        let secondFileName = "CHANGELOG"
        let secondFileExtension = "md"
        let secondText = formalFixes?.fixesApplied.map { "- \($0)" }.joined(separator: "\n") ?? "No changes applied."
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Choose Folder"

        panel.begin { response in
            guard response == .OK, let folderURL = panel.url else {
                completion(.failure(NSError(
                    domain: "ExportTextFiles",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "User cancelled export."]
                )))
                return
            }

            let firstURL = folderURL.appendingPathComponent("\(firstFileName).\(firstFileExtension)")
            let secondURL = folderURL.appendingPathComponent("\(secondFileName).\(secondFileExtension)")

            do {
                try firstText.write(to: firstURL, atomically: true, encoding: .utf8)
                try secondText.write(to: secondURL, atomically: true, encoding: .utf8)

                completion(.success([firstURL, secondURL]))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
