//
//  AccessibilityAnalysisFeedback.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 14.09.2025.
//

import SwiftUI

struct AccessibilityAnalysisFeedbackView: View {
    // MARK: - Properties
    let viewName: String?
    let formalFindings: AccessibilityAnalysisFormalFindings?
    let heuristicFindings: AccessibilityAnalysisHeuristicFindings?
    
    // MARK: - Closures
    let export: () -> Void
    
    // MARK: - Body
    var body: some View {
        Group {
            if formalFindings != nil || heuristicFindings != nil {
                VStack(alignment: .leading, spacing: Constant.headerSpacing) {
                    headerView
                    
                    Divider()
                    
                    HStack(alignment: .top, spacing: Constant.sectionSpacing) {
                        formalChecksSection
                        heuristicChecksSection
                    }
                    
                    HStack {
                        Spacer()
                        
                        PrimaryActionButton(
                            title: Strings.AccessibilityAnalyzer.exportButtonTitle,
                            isLoading: false
                        ) {
                            export()
                        }
                        
                        Spacer()
                    }
                }
                .padding()
            } else {
                Text(Strings.AccessibilityAnalyzer.noResultsPlaceholder)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Colors.appDarkGray1)
        .cornerRadius(Constant.cornerRadius)
    }
}

// MARK: - Private
private extension AccessibilityAnalysisFeedbackView {
    var headerView: some View {
        HStack {
            Text("\(Strings.AccessibilityAnalyzer.viewTitle) \(viewName ?? "Unknown")")
                .font(.headline)
            
            Spacer()
            
            Text("\(Strings.AccessibilityAnalyzer.scoreTitle) \(combinedScore) / 10")
                .font(.title3)
                .bold()
        }
    }
    
    var formalChecksSection: some View {
        VStack(alignment: .leading, spacing: Constant.contentSpacing) {
            Text("Formal checks")
                .font(.headline)
            
            if let formalFindings = formalFindings {
                Text("\(Strings.AccessibilityAnalyzer.scoreTitle) \(formalFindings.score) / 10")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if formalFindings.formalFindings.isEmpty {
                    Text(Strings.AccessibilityAnalyzer.noIssuesFound)
                        .foregroundColor(.green)
                        .font(.body)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: Constant.contentSpacing) {
                            ForEach(formalFindings.formalFindings, id: \.id) { finding in
                                prepareFormalFindingView(finding: finding)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            } else {
                Text(Strings.AccessibilityAnalyzer.noResultsPlaceholder)
                    .foregroundColor(.secondary)
                    .font(.body)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    var heuristicChecksSection: some View {
        VStack(alignment: .leading, spacing: Constant.contentSpacing) {
            Text("Heuristic checks")
                .font(.headline)
            
            if let heuristicFindings = heuristicFindings {
                Text("\(Strings.AccessibilityAnalyzer.scoreTitle) \(heuristicFindings.score) / 10")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if heuristicFindings.heuristicFindings.isEmpty &&
                    heuristicFindings.runtimeValidationRecommended.isEmpty {
                    Text(Strings.AccessibilityAnalyzer.noIssuesFound)
                        .foregroundColor(.green)
                        .font(.body)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: Constant.contentSpacing) {
                            ForEach(heuristicFindings.heuristicFindings, id: \.id) { finding in
                                prepareHeuristicFindingView(finding: finding)
                            }
                            
                            if !heuristicFindings.runtimeValidationRecommended.isEmpty {
                                VStack(alignment: .leading, spacing: Constant.contentSpacing) {
                                    Text("Runtime validation recommended")
                                        .font(.subheadline)
                                        .bold()
                                    
                                    ForEach(
                                        Array(heuristicFindings.runtimeValidationRecommended.enumerated()),
                                        id: \.offset
                                    ) { _, recommendation in
                                        prepareRuntimeValidationView(recommendation: recommendation)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            } else {
                Text(Strings.AccessibilityAnalyzer.noResultsPlaceholder)
                    .foregroundColor(.secondary)
                    .font(.body)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    var combinedScore: Int {
        let scores = [formalFindings?.score, heuristicFindings?.score].compactMap { $0 }
        guard !scores.isEmpty else { return 0 }
        return scores.reduce(0, +) / scores.count
    }
    
    func prepareFormalFindingView(
        finding: AccessibilityAnalysisFormalFindings.FormalFinding
    ) -> some View {
        VStack(alignment: .leading, spacing: Constant.issueViewSpacing) {
            HStack {
                Text(finding.category.formatted())
                    .font(.headline)
                
                Spacer()
                
                Text("\(Strings.AccessibilityAnalyzer.severityTitle) \(finding.severity.rawValue.capitalized)")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            (
                Text("Evidence:").bold() +
                Text(" \(finding.evidence)")
            )
            .font(.body)
            
            (
                Text("Why it matters:").bold() +
                Text(" \(finding.whyItMatters)")
            )
            .font(.subheadline)
            
            (
                Text("Suggested fix:").bold() +
                Text(" \(finding.suggestedFix)")
            )
            .font(.subheadline)
            .foregroundColor(.blue)
            
            (
                Text("Confidence:").bold() +
                Text(" \(finding.confidence.rawValue.capitalized)")
            )
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(Constant.cornerRadius)
    }
    
    func prepareHeuristicFindingView(
        finding: AccessibilityAnalysisHeuristicFindings.HeuristicFinding
    ) -> some View {
        VStack(alignment: .leading, spacing: Constant.issueViewSpacing) {
            HStack {
                Text(finding.category.formatted())
                    .font(.headline)
                
                Spacer()
                
                Text("\(Strings.AccessibilityAnalyzer.severityTitle) \(finding.severity.rawValue.capitalized)")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            (
                Text("Rationale:").bold() +
                Text(" \(finding.rationale)")
            )
            .font(.body)
            
            (
                Text("Potential user impact:").bold() +
                Text(" \(finding.potentialUserImpact)")
            )
            .font(.subheadline)
            
            (
                Text("Suggested improvement:").bold() +
                Text(" \(finding.suggestedImprovement)")
            )
            .font(.subheadline)
            .foregroundColor(.blue)
            
            (
                Text("Confidence:").bold() +
                Text(" \(finding.confidence.rawValue.capitalized)")
            )
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(Constant.cornerRadius)
    }
    
    func prepareRuntimeValidationView(
        recommendation: AccessibilityAnalysisHeuristicFindings.RuntimeValidationRecommendation
    ) -> some View {
        VStack(alignment: .leading, spacing: Constant.issueViewSpacing) {
            Text(recommendation.area.formatted())
                .font(.headline)
            
            Text(recommendation.reason)
                .font(.body)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(Constant.cornerRadius)
    }
}

// MARK: - Constants
private enum Constant {
    static let cornerRadius: CGFloat = 8.0
    static let headerSpacing: CGFloat = 16.0
    static let contentSpacing: CGFloat = 12.0
    static let issueViewSpacing: CGFloat = 4.0
    static let sectionSpacing: CGFloat = 16.0
}
