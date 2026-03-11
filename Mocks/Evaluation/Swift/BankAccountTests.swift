import XCTest

final class BankAccountTests: XCTestCase {
    func testDepositIncreasesBalance() {
        var account = BankAccount(id: 1, balance: 100)
        account.deposit(50)
        XCTAssertEqual(account.balance, 150)
    }

    func testWithdrawDecreasesBalance() throws {
        var account = BankAccount(id: 1, balance: 200)
        try account.withdraw(50)
        XCTAssertEqual(account.balance, 150)
    }
}
