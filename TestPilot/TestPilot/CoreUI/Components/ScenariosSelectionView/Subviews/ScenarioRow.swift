//
//  ScenarioRow.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 04.07.2025.
//

import SwiftUI

struct ScenarioRow: View {
    // MARK: - Properties
    @Binding var model: ScenarioRowModel

    // MARK: - Body
    var body: some View {
        HStack(alignment: .top, spacing: Constant.spacing) {
            Toggle("", isOn: $model.isSelected)
                .toggleStyle(CheckboxToggleStyle())
                .labelsHidden()

            Text(model.title)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding()
        .background(Color(.darkGray).opacity(0.6))
        .cornerRadius(Constant.cornerRadius)
    }
}

// MARK: - View constants
private enum Constant {
    static let spacing: CGFloat = 8
    static let cornerRadius: CGFloat = 6.0
}
