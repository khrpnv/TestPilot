//
//  AccessibilityAnalysisComponentDetailsView.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 10.03.2026.
//

import SwiftUI

struct AccessibilityAnalysisComponentDetailsView: View {
    let response: AccessibilityAnalysisComponentPurpose?

    var body: some View {
        VStack(alignment: .leading, spacing: Constant.sectionSpacing) {
            if let response {
                populatedState(response: response)
            } else {
                emptyState
            }
        }
        .padding(Constant.containerPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Colors.appDarkGray1)
        .clipShape(RoundedRectangle(cornerRadius: Constant.containerCornerRadius))
    }
}

// MARK: - States
private extension AccessibilityAnalysisComponentDetailsView {
    var emptyState: some View {
        VStack {
            Spacer()

            Text("Run the analysis to see component summary information.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constant.contentHorizontalPadding)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func populatedState(response: AccessibilityAnalysisComponentPurpose) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constant.sectionSpacing) {
                Text("Component Details")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, Constant.contentHorizontalPadding)

                detailCard(
                    emoji: "🧩",
                    title: "Component Name",
                    value: response.componentName
                )

                detailCard(
                    emoji: "💡",
                    title: "Component Purpose",
                    value: response.componentPurpose
                )

                detailCard(
                    emoji: "🖼️",
                    title: "UI Pattern",
                    value: response.uiPattern.displayName
                )

                detailCard(
                    emoji: "🏦",
                    title: "Domain Context",
                    value: response.domainContext.displayName
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    func detailCard(emoji: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(emoji)
                    .font(.title3)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.65))
            }

            Text(value)
                .font(.body)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Constant.cardContentPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Colors.appDarkGray1.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: Constant.itemCornerRadius))
        .padding(.horizontal, Constant.contentHorizontalPadding)
    }
}

// MARK: - Display names
private extension AccessibilityAnalysisComponentPurpose.UIPattern {
    var displayName: String {
        rawValue.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

private extension AccessibilityAnalysisComponentPurpose.DomainContext {
    var displayName: String {
        rawValue.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

// MARK: - Constants
private enum Constant {
    static let containerPadding: CGFloat = 16
    static let containerCornerRadius: CGFloat = 14
    static let sectionSpacing: CGFloat = 16
    static let itemCornerRadius: CGFloat = 10
    static let contentHorizontalPadding: CGFloat = 4
    static let cardContentPadding: CGFloat = 12
}
