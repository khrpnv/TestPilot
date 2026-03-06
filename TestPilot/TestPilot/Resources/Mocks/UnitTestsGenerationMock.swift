//
//  UnitTestsGenerationMock.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 29.06.2025.
//

import Foundation

enum UnitTestsGenerationMock {
    static let response = PromptResponse(
        choices: [
            .init(
                message: .init(
                    role: .assistant,
                    content: "```swift\nimport XCTest\n@testable import YourModuleName\n\nclass UserManagerTests: XCTestCase {\n\n    var userManager: UserManager!\n\n    override func setUp() {\n        super.setUp()\n        userManager = UserManager()\n    }\n\n    override func tearDown() {\n        userManager = nil\n        super.tearDown()\n    }\n\n    func testAddUser() {\n        let user = User(id: 1, name: \"John Doe\", email: \"john.doe@example.com\")\n        userManager.addUser(user)\n        let users = userManager.allUsers()\n\n        XCTAssertEqual(users.count, 1, \"Expected one user in list\")\n        XCTAssertEqual(users.first?.email, \"john.doe@example.com\", \"Email of the stored user does not match\")\n    }\n\n    func testFindUserByValidEmail() throws {\n        let user = User(id: 1, name: \"John Doe\", email: \"john.doe@example.com\")\n        userManager.addUser(user)\n\n        let foundUser = try userManager.findUser(byEmail: \"john.doe@example.com\")\n\n        XCTAssertEqual(foundUser.name, \"John Doe\", \"User should be found with correct name\")\n    }\n\n    func testFindUserByInvalidEmail() {\n        XCTAssertThrowsError(try userManager.findUser(byEmail: \"invalid.email\")) { error in\n            XCTAssertEqual(error as? UserError, UserError.invalidEmail, \"Expected invalid email error\")\n        }\n    }\n\n    func testFindUserNotFound() {\n        let user = User(id: 1, name: \"John Doe\", email: \"john.doe@example.com\")\n        userManager.addUser(user)\n\n        XCTAssertThrowsError(try userManager.findUser(byEmail: \"unknown@example.com\")) { error in\n            XCTAssertEqual(error as? UserError, UserError.notFound, \"Expected not found error\")\n        }\n    }\n\n    func testAllUsersInitiallyEmpty() {\n        let users = userManager.allUsers()\n        XCTAssertTrue(users.isEmpty, \"Expected no users initially\")\n    }\n\n    func testAllUsersAfterAddingMultiple() {\n        let user1 = User(id: 1, name: \"John Doe\", email: \"john.doe@example.com\")\n        let user2 = User(id: 2, name: \"Jane Smith\", email: \"jane.smith@example.com\")\n        \n        userManager.addUser(user1)\n        userManager.addUser(user2)\n        let users = userManager.allUsers()\n        \n        XCTAssertEqual(users.count, 2, \"Expected two users in list\")\n    }\n}\n```\n"
                )
            )
        ]
    )
}
