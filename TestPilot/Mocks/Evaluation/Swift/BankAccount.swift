struct BankAccount {
    let id: Int
    private(set) var balance: Double

    mutating func deposit(_ amount: Double) {
        balance += amount
    }

    mutating func withdraw(_ amount: Double) throws {
        guard balance >= amount else {
            throw NSError(domain: "BankAccount", code: 1, userInfo: nil)
        }
        balance -= amount
    }
}
