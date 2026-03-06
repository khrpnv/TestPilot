//
//  GenerateTestsView.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 28.06.2025.
//

import SwiftUI

struct GenerateTestsView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: GenerateTestsViewModel
    
    // MARK: - Body
    var body: some View {
        GeometryReader { (geometry) in
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: Constant.verticalSpacing) {
                    Text(viewModel.getTitle())
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(viewModel.getDescription())
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
                                title: Strings.GenerateTests.generateButtonTitle,
                                isLoading: viewModel.isGenerating
                            ) {
                                viewModel.generate()
                            }
                            
                            Spacer()
                        }
                        
                        SourceCodeView(
                            mode: viewModel.outputMode,
                            copyContentsAction: { (code) in
                                viewModel.copyToPasteboard(code)
                            }
                        )
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
}
