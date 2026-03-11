import SwiftUI

struct TransferFundsView: View {
    @State private var amount: String = ""
    @State private var recipient: String = ""

    var body: some View {
        Form {
            Section(header: Text("Recipient")) {
                TextField("Enter recipient name", text: $recipient)
            }

            Section(header: Text("Amount")) {
                TextField("Enter amount", text: $amount)
                    .keyboardType(.decimalPad)
            }

            Button(action: {
                // Perform transfer
            }) {
                Text("Send Money")
                    .font(.headline)
            }
        }
        .navigationTitle("Transfer Funds")
    }
}
