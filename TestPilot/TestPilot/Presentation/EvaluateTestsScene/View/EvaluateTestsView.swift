//
//  EvaluateTestsView.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 29.06.2025.
//

import SwiftUI

struct EvaluateTestsView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: EvaluateTestsViewModel

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: Constant.verticalSpacing) {
                    Text(Strings.EvaluateTests.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(Strings.EvaluateTests.description)
                        .foregroundColor(.white)
                        .font(.system(size: 17))
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: Constant.horizontalSpacing) {
                        VStack {
                            Text(Strings.EvaluateTests.sourceCodeTitle)
                                .foregroundStyle(.white)
                                .font(.title)
                            
                            SourceCodeView(mode: viewModel.codeInputMode) {
                                viewModel.openFile(code: true)
                            } copyContentsAction: { (contents) in
                                viewModel.copyToPasteboard(contents)
                            }
                        }

                        VStack {
                            Text(Strings.EvaluateTests.unitTestsTitle)
                                .foregroundStyle(.white)
                                .font(.title)
                            
                            SourceCodeView(mode: viewModel.testsInputMode) {
                                viewModel.openFile(code: false)
                            } copyContentsAction: { (contents) in
                                viewModel.copyToPasteboard(contents)
                            }
                        }
                    }

                    HStack {
                        Spacer()
                        
                        PrimaryActionButton(
                            title: Strings.EvaluateTests.evaluateButtonTitle,
                            isLoading: viewModel.isEvaluating
                        ) {
                            viewModel.evaluate()
                        }
                        
                        Spacer()
                    }

                    HStack {
                        Spacer()
                        
                        VStack(spacing: Constant.resultsContentSpacing) {
                            StarRatingView(score: viewModel.accuracyScore)
                            
                            EvaluationResultsView(results: viewModel.evaluationResults)
                                .frame(
                                    width: geometry.size.width * 0.5,
                                    height: (geometry.size.height - Constant.headerHeight) * 0.5
                                )
                        }
                            
                        Spacer()
                    }
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
