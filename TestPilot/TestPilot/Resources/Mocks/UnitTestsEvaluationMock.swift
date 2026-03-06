//
//  UnitTestsEvaluationMock.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 29.06.2025.
//

import Foundation

enum UnitTestsEvaluationMock {
    static let response = PromptResponse(
        choices: [
            .init(
                message: .init(
                    role: .assistant,
                    content: "**Strengths:**\n- The tests correctly validate the basic functionality of deposit and withdraw operations.\n- Use of XCTAssertEqual provides clear expectations of what the test is verifying.\n\n**Coverage:**\n- The tests cover normal scenarios for deposit and successful withdrawal.\n- There is no test coverage for withdrawing more than the available balance, which is a critical edge case and error scenario.\n  \n**Weaknesses:**\n- Lack of tests for error handling when withdrawing more than the account balance.\n- Doesn\'t test edge cases such as zero value deposits and withdrawals.\n- The private setter for balance can lead to tests inadvertently bypassing encapsulation if modified. There should be tests to ensure the accessor behavior isn\'t compromised.\n\n**Clarity and Maintainability:**\n- Test names are descriptive of the actions they are testing.\n- Tests are concise and easy to read, which aids maintainability.\n  \n**Suggestions:**\n- Add a test for an error when attempting to withdraw more than the current balance.\n- Include tests for depositing and withdrawing zero to check how the system handles these operations.\n- Consider testing for negative amounts being deposited or withdrawn, even if not currently handled in the code (speculative defense).\n- Consider refactoring error handling to use a specific error type instead of generic NSError for clarity and better Swift error management.\n\n**Accuracy Score:**\n- 3\n\n**Risk Assessment:**\n- Moderate risk of bugs related to insufficient error handling tests. Without testing edge cases and validation errors, the likelihood of encountering unexpected behavior in production code is increased."
                )
            )
        ]
    )
}
