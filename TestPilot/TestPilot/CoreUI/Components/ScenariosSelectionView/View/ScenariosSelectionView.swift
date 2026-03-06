//
//  ScenariosSelectionView.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 04.07.2025.
//

import SwiftUI

enum ScenariosSelectionViewAction {
    
}

struct ScenariosSelectionView: View {
    // MARK: - Properties
    @Binding var scenarios: [ScenarioRowModel]
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: Constant.contentSpacing) {
                if scenarios.isEmpty {
                    VStack {
                        Spacer()
                        Text(Strings.UserFlowsTests.noScenariosPlaceholder)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: Constant.itemsSpacing) {
                            ForEach(scenarios.indices, id: \.self) { index in
                                ScenarioRow(model: $scenarios[index])
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Colors.appDarkGray1)
            .cornerRadius(Constant.cornerRadius)
        }
    }
}

// MARK: - View constants
private enum Constant {
    static let contentSpacing: CGFloat = 12.0
    static let cornerRadius: CGFloat = 8.0
    static let itemsSpacing: CGFloat = 8.0
}
