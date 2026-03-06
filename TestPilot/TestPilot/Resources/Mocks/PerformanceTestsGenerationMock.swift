//
//  PerformanceTestsGenerationMock.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 14.09.2025.
//

import Foundation

enum PerformanceTestsGenerationMock {
    static let response = PromptResponse(
        choices: [
            .init(
                message: .init(
                    role: .assistant,
                    content: "```swift\nimport XCTest\n\nfinal class LoanCalculatorTests: XCTestCase {\n    var loanCalculator: LoanCalculator!\n    \n    override func setUp() {\n        super.setUp()\n        loanCalculator = LoanCalculator()\n    }\n    \n    override func tearDown() {\n        loanCalculator = nil\n        super.tearDown()\n    }\n    \n    func testCalculateMonthlyInstallmentPerformance() {\n        self.measure {\n            let amount = 100_000.0\n            let annualInterest = 5.0\n            let months = 360\n            let installment = loanCalculator.calculateMonthlyInstallment(amount: amount, annualInterest: annualInterest, months: months)\n            XCTAssertGreaterThan(installment, 0)\n        }\n    }\n    \n    func testGenerateAmortizationSchedulePerformance() {\n        self.measure {\n            let amount = 100_000.0\n            let annualInterest = 5.0\n            let months = 360\n            let schedule = loanCalculator.generateAmortizationSchedule(amount: amount, annualInterest: annualInterest, months: months)\n            XCTAssertEqual(schedule.count, months)\n        }\n    }\n    \n    func testHighVolumeAmortizationSchedulesPerformance() async {\n        await withTaskGroup(of: Void.self) { taskGroup in\n            for i in 0..<100 {\n                taskGroup.addTask {\n                    let amount = Double(10_000 * i)\n                    let annualInterest = 5.0 + Double(i % 10)\n                    let months = 360\n                    let schedule = self.loanCalculator.generateAmortizationSchedule(amount: amount, annualInterest: annualInterest, months: months)\n                    XCTAssertEqual(schedule.count, months)\n                }\n            }\n        }\n    }\n}\n```"
                )
            )
        ]
    )
}
