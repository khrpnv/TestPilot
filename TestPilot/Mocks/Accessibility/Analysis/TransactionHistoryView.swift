import SwiftUI

struct TransactionHistoryView: View {
    @State private var search: String = ""
    let accountNumber = "1234 5678 9012 3456"
    let transactions: [(title: String, amount: String, date: String)] = [
        ("Coffee Shop", "-$4.50", "Oct 1"),
        ("Salary", "+$3,200.00", "Sep 30"),
        ("Groceries", "-$86.12", "Sep 29")
    ]

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Account: \(accountNumber)")
                    .font(.headline)
                    .accessibilityLabel("Account number \(accountNumber)")
                Spacer()
                Button(action: {}) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 16))
                }
            }

            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $search)
                    .font(.system(size: 14))
            }
            .padding(8)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)

            List {
                ForEach(transactions.indices, id: \.self) { i in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(transactions[i].title)
                                .font(.system(size: 15))
                            Text(transactions[i].date)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text(transactions[i].amount)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Button(action: {}) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 14))
                        }
                        .padding(.leading, 4)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
    }
}
