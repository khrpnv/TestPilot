import Foundation

struct MathUtils {
    static func factorial(_ n: Int) -> Int {
        guard n >= 0 else { return 0 }
        return n <= 1 ? 1 : n * factorial(n - 1)
    }
}
