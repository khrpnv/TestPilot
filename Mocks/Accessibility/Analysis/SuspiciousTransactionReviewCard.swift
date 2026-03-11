import SwiftUI

struct SuspiciousTransactionReviewCard: View {
    @State private var isCardLocked = false
    @State private var notifyMerchant = true
    @State private var selectedReason: String? = "I don't recognize this merchant"

    private let merchant = "NOVA ELECTRONICS"
    private let amount = "$482.19"
    private let date = "Today, 2:14 PM"
    private let cardName = "Everyday Cashback"
    private let lastFour = "4821"

    private let reasons = [
        "I don't recognize this merchant",
        "Amount looks incorrect",
        "I made this purchase",
        "I was charged twice"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            transactionSummary

            Divider()

            actionArea

            Divider()

            footerActions
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(.separator).opacity(0.4), lineWidth: 1)
        )
        .padding()
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Suspicious activity detected")
                    .font(.headline)

                Text("Review this transaction to help secure your account.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Circle()
                .fill(isCardLocked ? Color.red : Color.green)
                .frame(width: 10, height: 10)
                .padding(.top, 6)
        }
    }

    private var transactionSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(merchant)
                        .font(.headline)

                    Text(date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(amount)
                    .font(.title3.weight(.semibold))
            }

            HStack(spacing: 12) {
                Image(systemName: "creditcard")
                    .foregroundStyle(.blue)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(cardName) •••• \(lastFour)")
                        .font(.subheadline)

                    Text(isCardLocked ? "Locked" : "Active")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(isCardLocked ? .red : .green)
                }

                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.systemBackground))
            )
        }
    }

    private var actionArea: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("What would you like to do?")
                .font(.subheadline.weight(.semibold))

            VStack(spacing: 10) {
                ForEach(reasons, id: \.self) { reason in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .strokeBorder(
                                    selectedReason == reason ? Color.accentColor : Color.gray.opacity(0.5),
                                    lineWidth: 2
                                )
                                .frame(width: 22, height: 22)

                            if selectedReason == reason {
                                Circle()
                                    .fill(Color.accentColor)
                                    .frame(width: 10, height: 10)
                            }
                        }

                        Text(reason)
                            .font(.subheadline)

                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemBackground))
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedReason = reason
                    }
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Lock card")
                        .font(.subheadline.weight(.medium))

                    Text("Temporarily prevent new purchases")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                ZStack(alignment: isCardLocked ? .trailing : .leading) {
                    Capsule()
                        .fill(isCardLocked ? Color.red : Color.gray.opacity(0.25))
                        .frame(width: 52, height: 32)

                    Circle()
                        .fill(Color.white)
                        .frame(width: 28, height: 28)
                        .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                        .padding(2)
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isCardLocked.toggle()
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.systemBackground))
            )

            Toggle(isOn: $notifyMerchant) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notify merchant")
                        .font(.subheadline.weight(.medium))

                    Text("Share that this payment is under review")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .toggleStyle(SwitchToggleStyle())
        }
    }

    private var footerActions: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button {
                    // Demo action
                } label: {
                    Text("This was me")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)

                Button {
                    // Demo action
                } label: {
                    Text("Report issue")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
            }

            HStack {
                Text("Need help?")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "phone.fill")
                        .font(.caption)

                    Text("Call")
                        .font(.footnote.weight(.medium))
                }
                .foregroundStyle(.blue)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.12))
                )
                .onTapGesture {
                    // Demo action
                }
            }
        }
    }
}

#Preview {
    SuspiciousTransactionReviewCard()
}
