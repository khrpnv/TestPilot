struct TransferFundsView: View {
    @State private var fromAccount = "Checking"
    @State private var toAccount = "Savings"
    @State private var amount = ""
    @State private var confirmationMessage: String?

    let accounts = ["Checking", "Savings", "Credit"]

    var body: some View {
        VStack(spacing: 16) {
            Text("Transfer Funds")
                .font(.title)
                .accessibilityIdentifier("title")

            Picker("From Account", selection: $fromAccount) {
                ForEach(accounts, id: \.self) { account in
                    Text(account)
                }
            }
            .accessibilityIdentifier("fromAccountPicker")

            Picker("To Account", selection: $toAccount) {
                ForEach(accounts, id: \.self) { account in
                    Text(account)
                }
            }
            .accessibilityIdentifier("toAccountPicker")

            TextField("Amount", text: $amount)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accessibilityIdentifier("amountField")

            Button("Transfer") {
                if amount.isEmpty || Double(amount) == nil {
                    confirmationMessage = "Enter a valid amount."
                } else {
                    confirmationMessage = "Transferred $\(amount) from \(fromAccount) to \(toAccount)."
                }
            }
            .accessibilityIdentifier("transferButton")

            if let message = confirmationMessage {
                Text(message)
                    .foregroundColor(.green)
                    .accessibilityIdentifier("confirmationMessage")
            }
        }
        .padding()
    }
}
