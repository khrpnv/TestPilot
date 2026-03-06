//
//  PrimaryRedButton.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 28.06.2025.
//

import SwiftUI

struct PrimaryRedButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Colors.appRed)
            .foregroundColor(.white)
            .cornerRadius(Constant.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

// MARK: - Constants
private enum Constant {
    static let cornerRadius: CGFloat = 8
}
