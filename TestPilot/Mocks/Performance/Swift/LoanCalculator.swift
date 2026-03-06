import Foundation

struct LoanCalculator {
    func calculateMonthlyInstallment(amount: Double, annualInterest: Double, months: Int) -> Double {
        let rate = annualInterest / 100.0 / 12.0
        return (amount * rate) / (1 - pow(1 + rate, Double(-months)))
    }
    
    func generateAmortizationSchedule(amount: Double, annualInterest: Double, months: Int) -> [Double] {
        let monthly = calculateMonthlyInstallment(amount: amount, annualInterest: annualInterest, months: months)
        return Array(repeating: monthly, count: months)
    }
}
