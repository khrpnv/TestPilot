//
//  PrimaryActionButton.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 28.06.2025.
//

import SwiftUI

struct PrimaryActionButton: View {
    // MARK: - Properties
    let title: String
    let isLoading: Bool
    let action: () -> Void

    // MARK: - Body
    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Text(title)
            }
        }
        .buttonStyle(PrimaryRedButton())
        .disabled(isLoading)
    }
}
