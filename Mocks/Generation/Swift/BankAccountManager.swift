import Foundation

struct BankAccount {
    let id: Int
    let owner: String
    private(set) var balance: Double
}

enum BankAccountError: Error {
    case insufficientFunds
    case accountNotFound
}

class BankAccountManager {
    private var accounts: [BankAccount] = []

    func createAccount(_ account: BankAccount) {
        accounts.append(account)
    }

    func deposit(to accountId: Int, amount: Double) throws {
        guard let index = accounts.firstIndex(where: { $0.id == accountId }) else {
            throw BankAccountError.accountNotFound
        }
        accounts[index] = BankAccount(
            id: accounts[index].id,
            owner: accounts[index].owner,
            balance: accounts[index].balance + amount
        )
    }

    func withdraw(from accountId: Int, amount: Double) throws {
        guard let index = accounts.firstIndex(where: { $0.id == accountId }) else {
            throw BankAccountError.accountNotFound
        }
        let currentBalance = accounts[index].balance
        guard currentBalance >= amount else {
            throw BankAccountError.insufficientFunds
        }
        accounts[index] = BankAccount(
            id: accounts[index].id,
            owner: accounts[index].owner,
            balance: currentBalance - amount
        )
    }

    func balance(for accountId: Int) throws -> Double {
        guard let account = accounts.first(where: { $0.id == accountId }) else {
            throw BankAccountError.accountNotFound
        }
        return account.balance
    }
}
