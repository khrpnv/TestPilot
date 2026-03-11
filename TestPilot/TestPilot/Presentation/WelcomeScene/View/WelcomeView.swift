//
//  WelcomeView.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 28.06.2025.
//

import SwiftUI

struct WelcomeView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: WelcomeViewModel
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: Constant.contentSpacing) {
            Assets.Shared.Images.logo
                .resizable()
                .cornerRadius(Constant.logoCornerRadius)
                .frame(width: Constant.logoSize, height: Constant.logoSize)
            
            Text(Strings.Welcome.title)
                .font(.system(size: 30))
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            Text(Strings.Welcome.description)
                .font(.system(size: 17))
                .foregroundColor(Color(.white))
                .multilineTextAlignment(.center)
                .frame(maxWidth: Constant.descriptionMaxWidth)
            
            HStack(spacing: Constant.buttonsStackSpacing) {
                Button {
                    viewModel.accessibility()
                } label: {
                    prepareButtonLabel(Strings.Welcome.accessibilityAnalyzerButtonTitle)
                }
                .buttonStyle(PrimaryRedButton())
            }
        }
        .padding()
        .containerRelativeFrame([.horizontal, .vertical])
        .background(Colors.appDarkGray)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottomTrailing) {
            modelMenu
                .padding(.trailing, 20)
                .padding(.bottom, 20)
        }
    }
}

// MARK: - Private
private extension WelcomeView {
    var modelMenu: some View {
        Menu {
            ForEach(PromptModel.allCases, id: \.self) { model in
                Button {
                    viewModel.selectModel(model)
                } label: {
                    if viewModel.selectedModel == model {
                        Label(model.rawValue, systemImage: "checkmark")
                    } else {
                        Text(model.rawValue)
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "cpu")
                Text(viewModel.selectedModel.rawValue)
                    .fixedSize()
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.35))
            .clipShape(Capsule())
            .fixedSize()
        }
        .fixedSize()
    }
    
    func prepareButtonLabel(_ content: String) -> some View {
        return Text(content)
            .font(.system(size: 14))
    }
}

// MARK: - Constants
private enum Constant {
    static let contentSpacing: CGFloat = 30.0
    static let logoSize: CGFloat = 150.0
    static let logoCornerRadius: CGFloat = 10.0
    static let buttonsStackSpacing: CGFloat = 20.0
    static let descriptionMaxWidth: CGFloat = 600.0
    static let commingSoonContentSpacing: CGFloat = 10.0
}
