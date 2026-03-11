import XCTest

final class UserValidatorTests: XCTestCase {
    func testValidUserReturnsTrue() {
        let user = User(username: "john", email: "john@example.com", age: 25)
        XCTAssertTrue(UserValidator.isValid(user))
    }

    func testEmptyUsernameReturnsFalse() {
        let user = User(username: "", email: "john@example.com", age: 25)
        XCTAssertFalse(UserValidator.isValid(user))
    }

    func testInvalidEmailReturnsFalse() {
        let user = User(username: "john", email: "invalidemail", age: 25)
        XCTAssertFalse(UserValidator.isValid(user))
    }

    func testUnderageUserReturnsFalse() {
        let user = User(username: "john", email: "john@example.com", age: 17)
        XCTAssertFalse(UserValidator.isValid(user))
    }
}
