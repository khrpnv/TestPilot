import SwiftUI

struct RecipientPickerRow: View {
    @State private var isFavorite = true
    @State private var isSelected = false

    private let recipientName = "Jordan Lee"
    private let bankName = "Chase Bank"
    private let maskedAccount = "•••• 1842"

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 44, height: 44)

                Text("JL")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(recipientName)
                        .font(.subheadline.weight(.semibold))

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }

                Text("\(bankName) • \(maskedAccount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(spacing: 8) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .foregroundStyle(.yellow)
                    .onTapGesture {
                        isFavorite.toggle()
                    }

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isSelected ? Color.blue.opacity(0.08) : Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1.5)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            isSelected.toggle()
        }
        .padding()
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    RecipientPickerRow()
}
