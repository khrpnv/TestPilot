import SwiftUI

struct SavingsGoalProgressCard: View {
    @State private var autoSaveEnabled = true

    private let goalName = "Emergency Fund"
    private let currentAmount: Double = 4200
    private let targetAmount: Double = 6000
    private let nextContribution = "$150 on Mar 15"
    private let accountName = "Smart Savings"

    private var progress: Double {
        currentAmount / targetAmount
    }

    private var remainingAmount: Double {
        max(targetAmount - currentAmount, 0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            progressSection
            detailsSection
            autoSaveSection
            actionsSection
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(.separator).opacity(0.25), lineWidth: 1)
        )
        .padding()
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "target")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.12))
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(goalName)
                    .font(.headline)

                Text("Savings goal")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("On track")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.green.opacity(0.14))
                )
                .foregroundStyle(.green)
                .accessibilityLabel("Status: On track")
        }
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(currency(currentAmount))
                    .font(.title2.weight(.bold))

                Text("of \(currency(targetAmount))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .accessibilityLabel("Savings progress")
                .accessibilityValue("\(Int(progress * 100)) percent complete")

            Text("\(currency(remainingAmount)) remaining to reach your target")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .contain)
    }

    private var detailsSection: some View {
        VStack(spacing: 12) {
            detailRow(
                title: "Linked account",
                value: accountName,
                icon: "building.columns"
            )

            detailRow(
                title: "Next auto-save",
                value: nextContribution,
                icon: "calendar"
            )
        }
    }

    private var autoSaveSection: some View {
        Toggle(isOn: $autoSaveEnabled) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Automatic savings")
                    .font(.subheadline.weight(.medium))

                Text("Move money into this goal on your scheduled dates")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .toggleStyle(.switch)
    }

    private var actionsSection: some View {
        HStack(spacing: 12) {
            Button {
                // Demo action
            } label: {
                Text("Add Money")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button {
                // Demo action
            } label: {
                Text("View Details")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .accessibilityElement(children: .contain)
    }

    private func detailRow(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
                .accessibilityHidden(true)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.medium))
                .multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value)")
    }

    private func currency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "US_us")
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

#Preview {
    SavingsGoalProgressCard()
}
