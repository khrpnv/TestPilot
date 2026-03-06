//
//  FeedbackRow.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 29.06.2025.
//

import SwiftUI

struct FeedbackRow: View {
    // MARK: - Properties
    let item: FeedbackItem

    // MARK: - Body
    var body: some View {
        HStack(alignment: .top, spacing: Constant.contentSpacing) {
            Text(item.text)
                .foregroundColor(.white)
                .font(.system(size: 15.0))
        }
    }
}

// MARK: - Constants
private enum Constant {
    static let contentSpacing: CGFloat = 8.0
    static let iconSize: CGFloat = 20.0
}
