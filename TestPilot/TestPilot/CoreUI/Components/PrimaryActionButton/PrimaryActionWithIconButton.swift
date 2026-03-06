//
//  PrimaryActionWithIconButton.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 04.07.2025.
//

import SwiftUI

struct PrimaryActionWithIconButton: View {
    // MARK: - Properties
    let icon: Image
    let isLoading: Bool
    let action: () -> Void

    // MARK: - Body
    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                icon
            }
        }
        .buttonStyle(PrimaryRedButton())
        .disabled(isLoading)
    }
}
