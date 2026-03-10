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
        GeometryReader { _ in
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
                        leftSection
                        
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
                        
                        rightSection
                    }
                }
                .padding()
                
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
            .background(Colors.appDarkGray)
        }
    }
}

// MARK: - Subviews
private extension AccessibilityAnalyzerView {
    var leftSection: some View {
        VStack(alignment: .leading, spacing: Constant.verticalSpacing) {
            HStack(alignment: .top, spacing: Constant.horizontalSpacing) {
                SourceCodeView(mode: viewModel.inputMode) {
                    viewModel.openFile()
                } copyContentsAction: { code in
                    viewModel.copyToPasteboard(code)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if let previewImage = viewModel.preview {
                    previewImage
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: Constant.cornerRadius))
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            
            HStack {
                Spacer()
                
                PrimaryActionButton(
                    title: Strings.AccessibilityAnalyzer.purposeButtonTitle,
                    isLoading: viewModel.purposeAnalyzing
                ) {
                    viewModel.analyzePurpose()
                }
                
                Spacer()
            }
            
            AccessibilityAnalysisComponentDetailsView(response: viewModel.purposeDetails)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    var rightSection: some View {
        VStack(alignment: .leading, spacing: Constant.verticalSpacing) {
            HStack(spacing: Constant.horizontalSpacing) {
                AccessibilityAnalysisFeedbackView(
                    viewName: viewModel.feedback?.view,
                    formalFindings: viewModel.feedback?.formal,
                    heuristicFindings: viewModel.feedback?.heuristic
                ) {
                    viewModel.export()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - Constants
private enum Constant {
    static let verticalSpacing: CGFloat = 16.0
    static let horizontalSpacing: CGFloat = 16.0
    static let closeButtonPadding: CGFloat = 14.0
    static let previewHeight: CGFloat = 220.0
    static let cornerRadius: CGFloat = 12.0
    static let sourceSectionHeight: CGFloat = 320
}
