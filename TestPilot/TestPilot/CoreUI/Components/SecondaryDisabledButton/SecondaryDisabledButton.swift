//
//  SecondaryDisabledButton.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 04.07.2025.
//

import SwiftUI

struct SecondaryDisabledButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color(.darkGray))
            .foregroundColor(.gray)
            .cornerRadius(Constant.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(0.6)
    }
}

// MARK: - Constants
private enum Constant {
    static let cornerRadius: CGFloat = 8
}
