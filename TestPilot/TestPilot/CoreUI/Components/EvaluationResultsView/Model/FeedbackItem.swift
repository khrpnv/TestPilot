//
//  FeedbackItem.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 29.06.2025.
//

import Foundation

struct FeedbackItem: Identifiable, Hashable {
    let id = UUID()
    let text: String
}
