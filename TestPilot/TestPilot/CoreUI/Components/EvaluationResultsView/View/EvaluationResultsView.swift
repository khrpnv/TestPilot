//
//  EvaluationResultsView.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 29.06.2025.
//

import SwiftUI

struct EvaluationResultsView: View {
    // MARK: - Properties
    let results: [EvaluationResult]
    
    // MARK: - Body
    var body: some View {
        VStack {
            if !results.isEmpty {
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: Constant.contentSpacing) {
                        ForEach(results) { section in
                            VStack(alignment: .leading, spacing: Constant.feedbackSpacing) {
                                Text(section.title)
                                    .foregroundColor(.white)
                                    .font(.system(size: 18.0, weight: .semibold))
                                    .bold()
                                
                                ForEach(section.items) { item in
                                    FeedbackRow(item: item)
                                }
                            }
                            .padding(.vertical, Constant.feedbackPadding)
                            
                            Divider()
                        }
                    }
                }
            } else {
                Spacer()
                
                Text(Strings.EvaluateTests.noFeedbackTitle)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Colors.appDarkGray1)
        .cornerRadius(Constant.cornerRadius)
    }
}

// MARK: - Constants
private enum Constant {
    static let contentSpacing: CGFloat = 16.0
    static let headerSpacing: CGFloat = 16.0
    static let feedbackSpacing: CGFloat = 8.0
    static let feedbackPadding: CGFloat = 8.0
    static let cornerRadius: CGFloat = 8.0
}
