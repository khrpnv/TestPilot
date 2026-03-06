//
//  AccessibilityAnalyzerView.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 29.06.2025.
//

import SwiftUI

struct AccessibilityAnalyzerView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: AccessibilityAnalyzerViewModel

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: Constant.verticalSpacing) {
                    Text(Strings.AccessibilityAnalyzer.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(Strings.AccessibilityAnalyzer.description)
                        .foregroundColor(.white)
                        .font(.system(size: 17))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(spacing: Constant.horizontalSpacing) {
                        SourceCodeView(mode: viewModel.inputMode) {
                            viewModel.openFile()
                        } copyContentsAction: { (code) in
                            viewModel.copyToPasteboard(code)
                        }
                        
                        VStack {
                            Spacer()
                            
                            PrimaryActionButton(
                                title: Strings.AccessibilityAnalyzer.analyzeButtonTitle,
                                isLoading: viewModel.isAnalyzing
                            ) {
                                viewModel.analyze()
                            }
                            
                            Spacer()
                        }
                        
                        AccessibilityAnalysisFeedbackView(feedback: viewModel.feedback) {
                            viewModel.export()
                        }
                    }
                    .frame(height: geometry.size.height - Constant.headerHeight)
                }
                .padding()
                .background(Colors.appDarkGray)
                
                Button {
                    viewModel.close()
                } label: {
                    Assets.Shared.Icons.close
                        .foregroundStyle(.white)
                        .padding(Constant.closeButtonPadding)
                        .background(Colors.appRed)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding()
            }
        }
    }
}

// MARK: - Constants
private enum Constant {
    static let verticalSpacing: CGFloat = 16.0
    static let horizontalSpacing: CGFloat = 16.0
    static let headerHeight: CGFloat = 150.0
    static let closeButtonPadding: CGFloat = 14.0
    static let resultsContentSpacing: CGFloat = 10.0
}
