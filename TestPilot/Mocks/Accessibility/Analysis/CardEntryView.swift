import SwiftUI

struct CardEntryView: View {
    @State private var cardNumber: String = "4111 1111 1111 1111"
    @State private var expiry: String = ""
    @State private var cvv: String = ""
    @State private var saveCard: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer()
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                }
            }

            Text("Add Card")
                .font(.title2)

            Text("Card: \(cardNumber)")
                .font(.system(size: 14))
                .accessibilityLabel("Card number \(cardNumber)")

            VStack(alignment: .leading, spacing: 12) {
                TextField("Card Number", text: $cardNumber)
                    .keyboardType(.numberPad)
                    .font(.system(size: 14))

                HStack {
                    TextField("MM/YY", text: $expiry)
                        .keyboardType(.numbersAndPunctuation)
                        .font(.system(size: 14))

                    TextField("CVV", text: $cvv)
                        .keyboardType(.numberPad)
                        .font(.system(size: 14))
                }
            }

            Toggle("Save card", isOn: $saveCard)
                .font(.system(size: 14))

            Text("We’ll charge a small verification amount.")
                .font(.system(size: 12))
                .foregroundColor(.gray)

            Button("Pay") {
                // Perform payment
            }
            .padding(.vertical, 6)

            Spacer()
        }
        .padding()
    }
}
