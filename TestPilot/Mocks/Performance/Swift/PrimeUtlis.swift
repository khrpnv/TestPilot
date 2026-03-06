import Foundation

struct PrimeUtils {
    func isPrime(_ number: Int) -> Bool {
        guard number >= 2 else { return false }
        if number == 2 { return true }
        if number % 2 == 0 { return false }
        
        let maxDivisor = Int(Double(number).squareRoot())
        for divisor in 3...maxDivisor where divisor % 2 != 0 {
            if number % divisor == 0 {
                return false
            }
        }
        return true
    }
    
    func generatePrimes(upTo limit: Int) -> [Int] {
        var primes: [Int] = []
        for i in 2...limit {
            if isPrime(i) {
                primes.append(i)
            }
        }
        return primes
    }
}
