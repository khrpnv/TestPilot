//
//  UserFlowsTestsView.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 04.07.2025.
//

import SwiftUI

struct UserFlowsTestsView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: UserFlowsTestsViewModel
    
    // MARK: - Body
    var body: some View {
        GeometryReader { (geometry) in
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: Constant.verticalSpacing) {
                    Text(Strings.UserFlowsTests.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(Strings.UserFlowsTests.description)
                        .foregroundColor(.white)
                        .font(.system(size: 17))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(alignment: .center, spacing: Constant.horizontalSpacing) {
                        let availableWidth = geometry.size.width - Constant.buttonsWidth
                        let sourceCodeWidth = availableWidth * Constant.sourceCodeWidth
                        let scenarioWidth = availableWidth * Constant.scenarioWidth
                        
                        VStack {
                            Text(Strings.UserFlowsTests.sourceCodeTitle)
                                .foregroundStyle(.white)
                                .font(.title)
                            
                            SourceCodeView(mode: viewModel.inputMode) {
                                viewModel.openFile()
                            } copyContentsAction: { (code) in
                                viewModel.copyToPasteboard(code)
                            }
                        }
                        .frame(width: sourceCodeWidth)
                        
                        VStack {
                            Spacer()
                            
                            PrimaryActionWithIconButton(
                                icon: Assets.Shared.Icons.rightArrow,
                                isLoading: viewModel.isGeneratingUserFlows
                            ) {
                                viewModel.generateScenarios()
                            }
                            
                            Spacer()
                        }
                        
                        VStack {
                            Text(Strings.UserFlowsTests.testScenariosTitle)
                                .foregroundStyle(.white)
                                .font(.title)
                            
                            ScenariosSelectionView(scenarios: $viewModel.scenarios)
                        }
                        .frame(width: scenarioWidth)
                           
                        
                        VStack {
                            Spacer()
                            
                            PrimaryActionWithIconButton(
                                icon: Assets.Shared.Icons.rightArrow,
                                isLoading: viewModel.isGeneratingTests
                            ) {
                                viewModel.generateTests()
                            }
                            
                            Spacer()
                        }
                        
                        VStack {
                            Text(Strings.UserFlowsTests.testsTitle)
                                .foregroundStyle(.white)
                                .font(.title)
                            
                            SourceCodeView(
                                mode: viewModel.outputMode,
                                copyContentsAction: { (code) in
                                    viewModel.copyToPasteboard(code)
                                }
                            )
                        }
                        .frame(width: sourceCodeWidth)
                    }
                    .frame(height: geometry.size.height - Constant.headerHeight)
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
        }
    }
}

// MARK: - Constants
private enum Constant {
    static let verticalSpacing: CGFloat = 16.0
    static let closeButtonPadding: CGFloat = 14.0
    static let horizontalSpacing: CGFloat = 10.0
    static let headerHeight: CGFloat = 150.0
    static let sourceCodeWidth: CGFloat = (1 - Constant.scenarioWidth) / 2
    static let scenarioWidth: CGFloat = 0.25
    static let buttonsWidth: CGFloat = 170.0
}
