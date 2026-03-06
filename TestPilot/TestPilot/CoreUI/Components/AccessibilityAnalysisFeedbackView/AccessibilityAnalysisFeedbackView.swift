//
//  AccessibilityAnalysisFeedback.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 14.09.2025.
//

import SwiftUI

struct AccessibilityAnalysisFeedbackView: View {
    // MARK: - Properties
    let feedback: AccessibilityAnalysisFeedback?
    
    // MARK: - Closures
    let export: () -> Void
    
    // MARK: - Body
    var body: some View {
        Group {
            if let feedback = feedback {
                VStack(alignment: .leading, spacing: Constant.headerSpacing) {
                    HStack {
                        Text("\(Strings.AccessibilityAnalyzer.viewTitle) \(feedback.view)")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(Strings.AccessibilityAnalyzer.scoreTitle) \(feedback.score) / 10")
                            .font(.title3)
                            .bold()
                    }
                    
                    Divider()
                    
                    if feedback.issues.isEmpty {
                        Text(Strings.AccessibilityAnalyzer.noIssuesFound)
                            .foregroundColor(.green)
                            .font(.body)
                    } else {
                        VStack {
                            ScrollView {
                                VStack(alignment: .leading, spacing: Constant.contentSpacing) {
                                    ForEach(feedback.issues, id: \.id) { issue in
                                        prepareIssueView(issue: issue)
                                    }
                                }
                                .padding(.vertical)
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
    func prepareIssueView(issue: AccessibilityAnalysisFeedback.Issue) -> some View {
        return VStack(alignment: .leading, spacing: Constant.issueViewSpacing) {
            HStack {
                Text(issue.type)
                    .font(.headline)
                Spacer()
                Text("\(Strings.AccessibilityAnalyzer.lineTitle) #\(issue.line)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(issue.description)
                .font(.body)
            Text("\(Strings.AccessibilityAnalyzer.suggestionTitle) \(issue.suggestion)")
                .font(.subheadline)
                .foregroundColor(.blue)
            Text("\(Strings.AccessibilityAnalyzer.severityTitle) \(issue.severity.rawValue.capitalized)")
                .font(.caption)
                .foregroundColor(.red)
            if issue.manualCheck {
                Text(Strings.AccessibilityAnalyzer.manualCheckNeeded)
                    .font(.caption)
                    .foregroundColor(.orange)
            }
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
}
