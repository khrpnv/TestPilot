//
//  StarRatingView.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 04.07.2025.
//

import SwiftUI

struct StarRatingView: View {
    // MARK: - Properties
    let score: Int

    // MARK: - Body
    var body: some View {
        HStack(spacing: Constant.contentSpacing) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= score ? "star.fill" : "star")
                    .foregroundColor(index <= score ? .yellow : .gray)
                    .font(.largeTitle)
            }
        }
    }
}

// MARK: - View constants
private enum Constant {
    static let contentSpacing: CGFloat = 4.0
}
