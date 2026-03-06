//
//  SourceCodeView.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 28.06.2025.
//

import SwiftUI

struct SourceCodeView: View {
    // MARK: - Mode
    enum Mode {
        case select
        case preview(code: String, language: String)
        case text(content: String)
        case failure(message: String)
    }
    
    // MARK: - Properties
    let mode: Mode
    let openFileAction: (() -> Void)?
    let copyContentsAction: ((String) -> Void)?
    
    // MARK: - Init
    init(
        mode: Mode,
        openFileAction: (() -> Void)? = nil,
        copyContentsAction: ((String) -> Void)? = nil
    ) {
        self.mode = mode
        self.openFileAction = openFileAction
        self.copyContentsAction = copyContentsAction
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            Spacer()
            
            switch mode {
            case .select:
                Button {
                    openFileAction?()
                } label: {
                    Text(Strings.Shared.openFileButtonTitle)
                }
                .buttonStyle(PrimaryRedButton())
                .frame(width: Constant.openFileButtonWidth)
                
            case .text(let content):
                Text(content)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
                
            case .failure(let message):
                Text(message)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                
            case .preview(let code, let language):
                ZStack(alignment: .topTrailing) {
                    HighlightedCodeView(
                        code: code,
                        language: language
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Button {
                        copyContentsAction?(code)
                    } label: {
                        Assets.Shared.Icons.copy
                            .foregroundStyle(.white)
                            .padding(Constant.copyImagePadding)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, Constant.copyButtonPadding)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Colors.appDarkGray1)
        .cornerRadius(Constant.cornerRadius)
    }
}

// MARK: - Constants
private enum Constant {
    static let openFileButtonWidth: CGFloat = 200.0
    static let cornerRadius: CGFloat = 8.0
    static let copyImagePadding: CGFloat = 12.0
    static let copyButtonPadding: CGFloat = 8.0
}
