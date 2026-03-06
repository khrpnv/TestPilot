import Foundation

struct StringUtils {
    static func isPalindrome(_ text: String) -> Bool {
        let cleaned = text.lowercased().filter { $0.isLetter }
        return cleaned == String(cleaned.reversed())
    }
}
